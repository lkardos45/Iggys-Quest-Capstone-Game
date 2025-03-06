extends Area2D

class_name FirePower

func _ready():
	var spawn_tween = get_tree().create_tween()
	spawn_tween.tween_property(self, "position", position + Vector2(0, -16), .4)


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
