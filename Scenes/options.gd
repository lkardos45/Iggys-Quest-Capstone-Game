extends Control
var fullscreen = false
func _on_fullscreen_pressed():
	if fullscreen == false:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		fullscreen = true
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		fullscreen = false


func _on_back_pressed():
	get_tree().change_scene_to_file("res://Scenes/menu.tscn")


func _on_controls_pressed():
	get_tree().change_scene_to_file("res://Scenes/controls_screen.tscn")
