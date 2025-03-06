extends Block_Base

class_name Block

@onready var sprite_2d = $Sprite2D
@onready var sfx_block_bump = $sfx_block_bump
@onready var sfx_block_break = $sfx_block_break

func bump(power: Player.playerMode):
	if power == Player.playerMode.small:
		super.bump(power)
		sfx_block_bump.play()
	else:
		super.bump(power)
		sprite_2d.play("break")
		sfx_block_break.play()
		


func _on_sprite_2d_animation_finished():
	queue_free()
