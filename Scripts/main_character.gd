extends CharacterBody2D

class_name Player

@export_group("Movement")
const MAX_WALK_SPEED = 400.0  # Maximum player speed
const MAX_RUN_SPEED = 650.0 # Max player run speed
const WALK_ACCELERATION = 1500.0  # Walk acceleration rate
const RUN_ACCELERATION = 2000.0  # Run acceleration rate
const FRICTION = 1200.0  # Friction rate (controls sliding distance)
const JUMP_VELOCITY = -1200.0
signal points_scored(points: int)
@export_group("")

@export_group("Camera sync")
@export var playerCamera: Camera2D
@export_group("")

# References
@onready var sprite_2D = $Sprite2D
@onready var area_2d = $Area2D
@onready var area_collision_2d = $Area2D/AreaCollision2D
@onready var body_collision_2d = $BodyCollision2D
const POINTS_LABEL_SCENE = preload("res://Scenes/points_label.tscn")
const SMALL_PLAYER_COLLISION = preload("res://Collisions/small_player_collision.tres")
const BIG_PLAYER_COLLISION = preload("res://Collisions/big_player_collision.tres")
const FIRE_PROJECTILE = preload("res://Scenes/fire_projectile.tscn")
@onready var fire_marker = $Fire_Marker
@onready var pause_menu = $"../UI/PauseMenu"

@onready var sfx_jump = $sfx_jump
@onready var sfx_fire_attack = $sfx_fire_attack
@onready var sfx_power_up = $sfx_power_up
@onready var sfx_power_down = $sfx_power_down

@onready var music = $Music
@onready var sfx_death_2 = $sfx_death_2
@onready var boss = $"../Boss"




@export_group("Jumping on Enemies")
@export var min_stomp_degree = 35
@export var max_stomp_degree = 145
@export_group("")

# State of player
var is_dead = false
var invincible = false
var paused = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

enum playerMode { # Defines the player's current power-up state
	small,
	big,
	fire
}

# Stores the player's power-up state and sets the default to "Small"
var power
var animation_prefix = ""
var frame = 0
var projectile_limit = 2
var projectile_direction = 1

var current_scene_file

func _ready():
	if power != playerMode.small:
		power = PlayerData.power
	current_scene_file = get_tree().current_scene.scene_file_path

func _physics_process(delta):
	# Handles the camera limit
	updateCameraLimit()
	
	if Input.is_action_just_pressed("pause"):
		pauseMenu()
	
	# Handles player power-up animations
	if power == playerMode.small:
		animation_prefix = ""
	elif power == playerMode.big:
		animation_prefix = "big_"
	elif power == playerMode.fire:
		animation_prefix = "fire_"
		
	# Handles Walking and Running Animations
	if sprite_2D.animation != "fire_attack":
		if (velocity.x > 1 || velocity.x < -1):
			sprite_2D.play("%srun" % animation_prefix)
		else:
			sprite_2D.play("%sidle" % animation_prefix)
		
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		if sprite_2D.animation != "fire_attack":
			sprite_2D.play("%sjump" % animation_prefix)
	# Handles jumping
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		if !(sfx_jump.playing):
			sfx_jump.play()
		
	if Input.is_action_just_released("jump") and velocity.y < 0: # Player does a short jump if button is only tapped and not held
		velocity.y *= .5
	
	# Handles the player ducking
	if power == playerMode.big || power == playerMode.fire and sprite_2D.animation != "fire_attack":
		if Input.is_action_pressed("down") and is_on_floor() and !Input.is_action_pressed("left") and !Input.is_action_pressed("right"):
			sprite_2D.play("%sduck" % animation_prefix)
			set_collision_shapes(true)
			sprite_2D.offset = Vector2(0, 1)
		else:
			if Input.is_action_just_released("down") and is_on_floor():
				sprite_2D.offset = Vector2(0, 0)
			set_collision_shapes(false)
	

	# Get the input direction and handle acceleration/deceleration
	var direction = Input.get_axis("left", "right")
	var acceleration = WALK_ACCELERATION
	
	# Speed up if run button is held
	if Input.is_action_pressed("run"):
		acceleration = RUN_ACCELERATION
		
	if Input.is_action_just_pressed("run") and power == playerMode.fire:
		attack()

	# Apply acceleration based on input direction
	if abs(direction) > 0:  # Only apply force if there's input
		velocity.x += (direction * acceleration - velocity.x) * delta
		
	if (global_position.x < playerCamera.limit_left + 8 and sign(velocity.x) == -1):
		global_position.x = clamp(global_position.x, playerCamera.limit_left + 8, INF)
	
	# Handles the player colliding with objects such as blocks
	var collision = get_last_slide_collision()
	if collision != null:
		handle_movement_collision(collision) # passes the collision to the handle_movement_collision function
	
	# Apply friction when no input is pressed or when moving against current direction
	if direction == 0 or sign(direction) != sign(velocity.x):
		velocity.x = move_toward(velocity.x, 0.0, FRICTION * delta)
	
	# Determines if player is turning while not in the air
	if sign(direction) != sign(velocity.x) and velocity.y == 0 and direction != 0 and sprite_2D.animation != "jump":
		sprite_2D.play("%sturn" % animation_prefix)
	
	# Limit velocity to maximum speed
	if Input.is_action_pressed("run"):
		velocity.x = clamp(velocity.x, -MAX_RUN_SPEED, MAX_RUN_SPEED)
	else:
		velocity.x = clamp(velocity.x, -MAX_WALK_SPEED, MAX_WALK_SPEED)

	move_and_slide()  # Use move_and_slide for collision handling
	
	var isLeft = velocity.x < 0
	
	# Makes sure that the character faces the direction of last button input
	if Input.is_action_pressed('left'):
		sprite_2D.flip_h = true
		projectile_direction = -1
	if Input.is_action_pressed('right'):
		sprite_2D.flip_h = false
		projectile_direction = 1
		
		
func _process(delta):
	if global_position.x > playerCamera.global_position.x:
		playerCamera.global_position.x = global_position.x


func _on_area_2d_area_entered(area):
	if area is Enemy:
		handle_enemy_collision(area)
	if area is Berry:
		handle_berry_collision(area)
		area.queue_free()
	if area is FirePower:
		handle_fire_power_collision(area)
		area.queue_free()
		
func handle_enemy_collision(enemy: Enemy):
	if enemy == null:
		return
	if is_instance_of(enemy, Rolly) and (enemy as Rolly).in_ball:
		(enemy as Rolly).on_stomp(global_position)
		spawn_points_label(enemy)
	else:
		var angle_of_collision = rad_to_deg(position.angle_to_point(enemy.position))
		if angle_of_collision > min_stomp_degree && max_stomp_degree > angle_of_collision && enemy.jumpable == true:
			enemy.die()
			on_enemy_stomped()
			spawn_points_label(enemy)
		else:
			if invincible == false:
				death()
			else:
				return

func big_to_small():
	set_collision_layer_value(1, false)
	set_physics_process(false)
	if !(sfx_power_down.playing):
		sfx_power_down.play()
	var animation_name = "small_to_big" if power == playerMode.big else "big_to_fire"
	sprite_2D.play(animation_name, 1.0, true)
	iframes()
	if power == playerMode.small:
		set_collision_shapes(true)

# Handles the player death; both animation and reloading the scene
func death():
	if power == playerMode.small:
		is_dead = true
		sprite_2D.play("death") # Sets the sprite to the death sprite
		
		if !(sfx_death_2.playing):
			sfx_death_2.play()
		
		if (music.playing):
			music.stop()
		elif (boss.boss_music.playing):
			boss.boss_music.stop()
		
		# Disables collisions on death
		area_2d.set_collision_layer_value(1, false)
		area_2d.set_collision_mask_value(3, false)
		area_2d.set_collision_mask_value(6, false)
		set_collision_layer_value(1, false)
		set_collision_mask_value(3, false)
		set_collision_mask_value(6, false)
		set_physics_process(false)
		
		PlayerData.power = power
		
		# Creates the death animation
		var death_tween = get_tree().create_tween()
		death_tween.tween_property(self, "position", position + Vector2(0, -150), .3)
		death_tween.chain().tween_property(self, "position", position + Vector2(0, -200), .2)
		death_tween.chain().tween_property(self, "position", position + Vector2(0, 1000), 2)
		
		await get_tree().create_timer(3).timeout
		get_tree().reload_current_scene()
	else:
		big_to_small() # Makes the player lose their power if they have a power-up

# Handles the collision with the blocks
func handle_movement_collision(collision: KinematicCollision2D):
	if collision.get_collider() is Block:
		#print("block hit") # Used for testing that player and block collision works
		var collision_angle = rad_to_deg(collision.get_angle())
		if roundf(collision_angle) == 180:
			(collision.get_collider() as Block).bump(power)
	elif collision.get_collider() is Block_Item:
		#print("block hit") # Used for testing that player and block collision works
		var collision_angle = rad_to_deg(collision.get_angle())
		if roundf(collision_angle) == 180:
			(collision.get_collider() as Block_Item).bump(power)

# Handles the collision with berry power-ups
func handle_berry_collision(area: Node2D):
	if power == playerMode.big || power == playerMode.fire:
		return
	if power == playerMode.small:
		if !(sfx_power_up.playing):
			sfx_power_up.play()
		frame += 1
		set_physics_process(false)
		sprite_2D.play("small_to_big")
		set_collision_shapes(false)
		## iframes()
		if frame > 0:
			position.y += 4 # Fixes player being slighly in air during power-up transformation
			
# Handles the collision with fire power-ups
func handle_fire_power_collision(area: Node2D):
	if power == playerMode.fire:
		return
	set_physics_process(false)
	if power == playerMode.small:
		if !(sfx_power_up.playing):
			sfx_power_up.play()
		frame += 1
		sprite_2D.play("small_to_fire")
		if frame > 0:
			position.y += 4 # Fixes player being slighly in air during power-up transformation
	elif power == playerMode.big:
		if !(sfx_power_up.playing):
			sfx_power_up.play()
		sprite_2D.play("big_to_fire")
	set_collision_shapes(false)
	# iframes()

# Adds the point label for killed enemies
func spawn_points_label(enemy):
	var points_label = POINTS_LABEL_SCENE.instantiate()
	points_label.position = enemy.position + Vector2(-20, -20)
	get_tree().root.add_child(points_label)
	points_scored.emit(100)

# Controls the jump height when the player stomps on an enemy
func on_enemy_stomped():
	if Input.is_action_pressed("jump"):
		velocity.y = JUMP_VELOCITY
	else:
		velocity.y = JUMP_VELOCITY * .5

# Handles additional animations and power-up and power-down
func _on_sprite_2d_animation_finished():
	if sprite_2D.animation == "small_to_big":
		reset_player_properties()
		match power:
			playerMode.big:
				power = playerMode.small
				set_collision_shapes(true)
			playerMode.small:
				power = playerMode.big
	if sprite_2D.animation == "small_to_fire":
		reset_player_properties()
		match power:
			playerMode.fire:
				power = playerMode.small
				set_collision_shapes(true)
			playerMode.small:
				power = playerMode.fire
	if sprite_2D.animation == "big_to_fire":
		reset_player_properties()
		match power:
			playerMode.fire:
				power = playerMode.big
			playerMode.big:
				power = playerMode.fire
		
	if sprite_2D.animation == "fire_attack":
		sprite_2D.play("%sidle" % animation_prefix)

func reset_player_properties():
	set_physics_process(true)
	set_collision_layer_value(1, true)

func set_collision_shapes(is_small: bool):
	var collision_shape = SMALL_PLAYER_COLLISION if is_small else BIG_PLAYER_COLLISION
	area_collision_2d.set_deferred("shape", collision_shape)
	body_collision_2d.set_deferred("shape", collision_shape)
	
	if is_small: # Corrects the changed collision position
		area_collision_2d.set_deferred("position", Vector2(0, 3))
		body_collision_2d.set_deferred("position", Vector2(0, 3))
	else:
		area_collision_2d.set_deferred("position", Vector2(0, -5))
		body_collision_2d.set_deferred("position", Vector2(0, -5))

func attack():
	var projectile_count = get_tree().get_nodes_in_group("FIRE_PROJECTILE").size()
	if projectile_count < 2:
		sprite_2D.play("fire_attack")
		var fire = FIRE_PROJECTILE.instantiate()
		if !(sfx_fire_attack.playing):
			sfx_fire_attack.play()
		
		fire.direction = projectile_direction
		fire.scale.x *= projectile_direction
		fire.global_position = fire_marker.global_position
		get_tree().root.add_child(fire)
		fire.add_to_group("FIRE_PROJECTILE")
	else:
		pass
	
func iframes():
	invincible = true
	modulate.a = .5
	await get_tree().create_timer(2.5).timeout
	modulate.a = 1
	invincible = false
	
func updateCameraLimit():
	var viewport_rect = playerCamera.get_viewport_rect()
	var left_limit = playerCamera.global_position.x - (viewport_rect.size.x * 0.5) + 16
	playerCamera.limit_left = left_limit
	if playerCamera.limit_left < 0:
		playerCamera.limit_left = 0
	else:
		return

func pauseMenu():
	if paused:
		pause_menu.hide()
		Engine.time_scale = 1
		get_tree().paused = false
	else:
		pause_menu.show()
		Engine.time_scale = 0
		get_tree().paused = true
	paused = !paused
