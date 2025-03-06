extends Node2D
@onready var label_2 = $Label2

func _process(delta):
	label_2.text = "Score:\n%s" % PlayerData.points + "\n\nCoins:\n%s" % PlayerData.coins
	if Input.is_action_just_pressed("ui_accept"):
		PlayerData.coins = 0
		PlayerData.points = 0
		PlayerData.power = Player.playerMode.small
		PlayerData.world = 1
		PlayerData.level = 1
		get_tree().change_scene_to_file("res://Scenes/title_screen.tscn")
