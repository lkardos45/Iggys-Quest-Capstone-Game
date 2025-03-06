extends Area2D

const FILE_BEGIN = "res://Levels/"
@onready var sfx_goal = $sfx_goal
@onready var character_body_2d = $"../CharacterBody2D"
@onready var music = $"../CharacterBody2D/Music"
@onready var game_manager = %GameManager
@onready var boss = $"../Boss"

var world_number = PlayerData.world
var level_number = PlayerData.level

func _ready():
	var current_scene_file = get_tree().current_scene.scene_file_path


func _on_body_entered(body):
	if (body.name == "CharacterBody2D"):
		level_number += 1
		if level_number > 3:
			level_number = 1
			world_number += 1
		
		if !(sfx_goal.playing):
			sfx_goal.play()
		if (music.playing):
			music.stop()
		elif (boss.boss_music.playing):
			boss.boss_music.stop()
		
		character_body_2d.area_2d.set_collision_layer_value(1, false)
		character_body_2d.area_2d.set_collision_mask_value(3, false)
		character_body_2d.area_2d.set_collision_mask_value(6, false)
		set_collision_layer_value(1, false)
		set_collision_mask_value(3, false)
		set_collision_mask_value(6, false)
		character_body_2d.set_physics_process(false)
		character_body_2d.sprite_2D.pause()
		
		PlayerData.power = character_body_2d.power
		PlayerData.coins = game_manager.coins
		PlayerData.points = game_manager.points
		PlayerData.world = world_number
		PlayerData.level = level_number
		await get_tree().create_timer(4).timeout
		
		
		if (world_number == 4) && (level_number == 1): # If level was last, jump to end screen
			get_tree().change_scene_to_file("res://Scenes/end_screen.tscn")
		else:
			var next_level_path = FILE_BEGIN + "level_" + str(world_number) + "-" + str(level_number) + ".tscn"
			get_tree().change_scene_to_file(next_level_path)
