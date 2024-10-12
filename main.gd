extends Node2D

func _ready():
	EventManager.raise_event(str(EventManager.EVENT_NAMES.ON_GAME_PAUSE), [false])

func _on_new_game_pressed():
	get_tree().change_scene_to_file("res://difficulty_select.tscn")

func _on_quit_pressed():
	get_tree().quit()
