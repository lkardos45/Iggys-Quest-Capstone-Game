extends AnimatedSprite2D

func _ready():
	var coin_tween = get_tree().create_tween()
	coin_tween.tween_property(self, "position", position + Vector2(0, -70), .2)
	coin_tween.chain().tween_property(self, "position", position, .2)
	coin_tween.tween_callback(queue_free)
