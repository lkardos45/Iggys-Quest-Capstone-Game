extends Enemy

func _ready():
	jumpable = false

func die():
	super.die()
	set_collision_layer_value(3, false)
	set_collision_mask_value(1, false)
	get_tree().create_timer(.4).timeout.connect(queue_free)
