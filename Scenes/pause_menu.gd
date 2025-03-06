extends Control
@onready var character_body_2d = $"../../CharacterBody2D"
@onready var resume = $MarginContainer/VBoxContainer/Resume

func _process(delta):
	if Input.is_action_just_pressed("pause"):
		resume.grab_focus()

func _on_resume_pressed():
	character_body_2d.pauseMenu()

func _on_quit_pressed():
	get_tree().quit()
