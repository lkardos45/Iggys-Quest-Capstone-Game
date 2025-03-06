extends StaticBody2D

class_name Block_Base

@onready var ray_cast_2d = $RayCast2D as RayCast2D
# @onready var shape_cast_2d = $ShapeCast2D

func bump(power: Player.playerMode):
	var bump_tween = get_tree().create_tween()
	bump_tween.tween_property(self, "position", position + Vector2(0, -30), .05)
	bump_tween.chain().tween_property(self, "position", position, .12)
	check_for_enemy_collision()

func check_for_enemy_collision():
	if ray_cast_2d.is_colliding() && ray_cast_2d.get_collider() is Enemy:
		var enemy = ray_cast_2d.get_collider() as Enemy
		enemy.die_from_hit()
