extends Node2D

@export var speed = 400
var current_speed = 0

func _physics_process(delta):
	position.y += current_speed * delta

func _on_player_detection_area_entered(area):
	if area.get_parent() is Player:
		fall()

func _on_hitbox_body_entered(body):
	if (body is Player and body.invincible == false):
		body.death()
		queue_free()
		
func fall():
	current_speed = speed
	await get_tree().create_timer(5).timeout
	queue_free()
