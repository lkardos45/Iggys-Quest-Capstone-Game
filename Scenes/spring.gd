extends Node2D

@onready var sprite_2d = $Sprite2D
@onready var sfx_spring_high = $sfx_spring_high
@onready var sfx_spring_low = $sfx_spring_low

func ready():
	sprite_2d.play("idle")


func _on_hitbox_body_entered(body):
	if (body is Player):
		if Input.is_action_pressed("jump"):
			sprite_2d.play("spring")
			body.velocity.y = -2000
			sfx_spring_high.play()
		else:
			sprite_2d.play("spring", 2, false)
			body.velocity.y = -1000
			sfx_spring_low.play()
