extends Node


var coins = 0
var points = 0
var level_name = ""
@onready var coins_label = %CoinsLabel
@onready var ui_points_label = %UIPointsLabel
@onready var level_name_label = %LevelNameLabel
@onready var sfx_coin_collect = $sfx_coin_collect
@onready var goal = $"../Goal"
@onready var character_body_2d = $"../../CharacterBody2D"

func _ready():
	if PlayerData.points != 0:
		points = PlayerData.points
	if PlayerData.coins != 0:
		coins = PlayerData.coins
		
	coins_label.text = "Coins: " + str(coins)
	ui_points_label.text = "Points: " + str(points)
	
	if get_parent() == get_tree().current_scene:
		level_name_label.text = get_tree().current_scene.name
	else:
		return

func add_coin():
	sfx_coin_collect.play()
	coins += 1
	PlayerData.coins = coins
	print(coins)
	coins_label.text = "Coins: " + str(coins)

func add_points(value):
	points += value
	PlayerData.points = points
	ui_points_label.text = "Points: " + str(points)
	
