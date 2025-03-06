extends Enemy

class_name Enemy_Boss

var health = 20
@onready var timer = $Timer
@onready var music = $"../CharacterBody2D/Music"
@onready var boss_music = $BossMusic

func _ready():
	timer.start()
	jumpable = false
	horizontal_speed = 100
	
	
func _physics_process(_delta):
	super._physics_process(_delta)

func die_from_hit():
	timer.stop()
	health -= 1
	print(health)
	if health <= 0:
		super.die_from_hit()
		boss_music.stop()
	
func bossMove():
	var camera2D = get_tree().get_current_scene().get_node("Camera2D")
	var viewport_rect = camera2D.get_viewport_rect()
	var boss_right_limit = camera2D.global_position.x + (viewport_rect.size.x * 0.5) + 600
	if position.x < boss_right_limit:
		print("Boss is moving")
		horizontal_speed = 100
		var directionModifier = randi_range(0, 1)
		var jumpModifier = randi_range(0, 10)
		if directionModifier == 0:
			direction *= -1
		else:
			direction *= 1
		if jumpModifier >= 3: # Controls boss jumping
			var fly_tween = get_tree().create_tween()
			animated_sprite_2d.play("fly")
			fly_tween.tween_property(self, "position", position + Vector2(0, -200), .5)
			await get_tree().create_timer(1.2).timeout
			animated_sprite_2d.play("walk")
		else:
			animated_sprite_2d.play("walk")
	else:
		horizontal_speed = 0



func _on_timer_timeout():
	bossMove()
	print("Timer stopped")
	
func _on_visible_on_screen_notifier_2d_screen_exited():
	boss_music.stop()
	music.play()
	super._on_visible_on_screen_notifier_2d_screen_exited()

func _on_visible_on_screen_notifier_2d_screen_entered():
	music.stop()
	boss_music.play()
	
