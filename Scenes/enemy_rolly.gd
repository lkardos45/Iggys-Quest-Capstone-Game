extends Enemy

class_name Rolly

var in_ball = false
const ENEMY_ROLLY_COLLISION = preload("res://Collisions/enemy_rolly_collision.tres")
const ENEMY_ROLLY_BALL_COLLISION = preload("res://Collisions/enemy_rolly_ball_collision.tres")
const ENEMY_ROLLY_COLLISION_SHAPE_POSITION = Vector2(0, 12)
const ENEMY_ROLLY_BALL_COLLISION_SHAPE_POSITION = Vector2(0, 0)

@onready var collision_shape_2d = $CollisionShape2D
@export var roll_speed = 600

func _ready():
	collision_shape_2d.shape = ENEMY_ROLLY_COLLISION

func die():
	if !in_ball:
		super.die()

	collision_shape_2d.set_deferred("shape", ENEMY_ROLLY_BALL_COLLISION)
	collision_shape_2d.set_deferred("position", ENEMY_ROLLY_BALL_COLLISION_SHAPE_POSITION)
	in_ball = true
	vertical_speed = 300
	

func on_stomp(player_position: Vector2):
	set_collision_mask_value(1, false)
	set_collision_layer_value(3, false)
	set_collision_layer_value(4, true)
	
	vertical_speed = 300
	if player_position.x <= global_position.x or player_position.y > global_position.y:
		direction = 1
	else:
		direction = -1
	horizontal_speed = roll_speed
	animated_sprite_2d.play("roll")
	game_manager.add_points(100)
