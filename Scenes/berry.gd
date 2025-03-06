extends Area2D

class_name Berry

@export var horizontal_speed = 150
@export var MAX_VERTICAL_SPEED = 300
@export var vertical_velocity = .1
@onready var shape_cast_2d = $ShapeCast2D
@onready var ray_cast_2d_left = $RayCast2D_Left
@onready var ray_cast_2d_right = $RayCast2D_Right
@onready var character_body_2d = $"../CharacterBody2D"
@onready var sprite_2d = $Sprite2D

var allow_horizontal_movement = false
var vertical_speed = 0
var direction = 1

func _ready():
	var spawn_tween = get_tree().create_tween()
	spawn_tween.tween_property(self, "position", position + Vector2(0, -16), .4)
	spawn_tween.tween_callback(func (): allow_horizontal_movement = true)
	
	if position.x >= character_body_2d.position.x || position.x + 40 >= character_body_2d.position.x:
		direction = 1
	else:
		direction = -1
	
func _process(delta):
	if allow_horizontal_movement:
		position.x += delta * horizontal_speed * direction
		sprite_2d.play("roll")
	
	if !shape_cast_2d.is_colliding() && allow_horizontal_movement:
		vertical_speed = lerpf(vertical_speed, MAX_VERTICAL_SPEED, vertical_velocity)
		position.y += delta * vertical_speed
	else: 
		vertical_speed = 0
		
	# Check for collisions and update direction if needed
	if ray_cast_2d_left.is_colliding():
		direction = 1
	elif ray_cast_2d_right.is_colliding():
		direction = -1


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
