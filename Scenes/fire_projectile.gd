extends Area2D

class_name fire_projectile

@export var horizontal_speed = 700

var direction

func _process(delta):
	position.x += delta * horizontal_speed * direction

func _on_area_entered(area):
	if (area is Enemy):
		area.die_from_hit()
	queue_free()
	
func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
