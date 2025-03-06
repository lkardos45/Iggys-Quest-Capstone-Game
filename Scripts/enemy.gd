extends Area2D

class_name Enemy

const POINTS_LABEL_SCENE = preload("res://Scenes/points_label.tscn")

@export var horizontal_speed = 100
@export var vertical_speed = 300

@onready var ray_cast_2d = $RayCast2D
@onready var ray_cast_2d_left = $RayCast2D_Left
@onready var ray_cast_2d_right = $RayCast2D_Right
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var shape_cast_2d = $ShapeCast2D

@onready var game_manager = %GameManager
@onready var sfx_enemy_death = $sfx_enemy_death

var direction = -1
var flyingEnemy = false
var jumpable = true

func _physics_process(_delta):
	# Ensures the enemies only move when close to the screen
	var camera2D = get_tree().get_current_scene().get_node("Camera2D")
	var viewport_rect = camera2D.get_viewport_rect()
	var right_limit = camera2D.global_position.x + (viewport_rect.size.x * 0.5) + 600
	if position.x < right_limit:
		position.x += _delta * horizontal_speed * direction
		
		if (flyingEnemy == false):
		  # Check for collisions and update direction if needed
			if !shape_cast_2d.is_colliding():
				position.y += _delta * vertical_speed
			if ray_cast_2d_left.is_colliding():
				direction = 1
			elif ray_cast_2d_right.is_colliding():
				direction = -1

  # Update animation based on direction (optional)
	animated_sprite_2d.flip_h = direction > 0
	

func die():
	horizontal_speed = 0
	vertical_speed = 0
	game_manager.add_points(100)
	animated_sprite_2d.play("death")
	if !(sfx_enemy_death.playing):
		sfx_enemy_death.play()
	
func die_from_hit():
	set_collision_layer_value(3, false)
	set_collision_mask_value(3, false)
	set_collision_mask_value(4, false)
	
	rotation_degrees = 180
	vertical_speed = 0
	horizontal_speed = 0
	
	if !(sfx_enemy_death.playing):
		sfx_enemy_death.play()
	var die_tween = get_tree().create_tween()
	die_tween.tween_property(self, "position", position + Vector2(0, -25), .2)
	die_tween.chain().tween_property(self, "position", position + Vector2(0, 1000), 2)
	
	game_manager.add_points(100)
	
	var points_label = POINTS_LABEL_SCENE.instantiate()
	points_label.position = self.position + Vector2(-20, - 20)
	get_tree().root.add_child(points_label)

func _on_area_entered(area):
	if area is Rolly and (area as Rolly).in_ball and (area as Rolly).horizontal_speed != 0:
		die_from_hit()
		
func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
