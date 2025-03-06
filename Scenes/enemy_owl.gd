extends Enemy

func _ready():
	horizontal_speed = 300
	flyingEnemy = true

func die():
	super.die()
	set_collision_layer_value(3, false)
	set_collision_mask_value(1, false)
	get_tree().create_timer(.4).timeout.connect(queue_free)

func die_from_hit():
	super.die_from_hit()
	animated_sprite_2d.play("rolly_death")
