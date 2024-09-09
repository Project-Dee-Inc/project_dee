extends Node2D

func _ready() -> void:
	if randi() % 2 == 0:
		$TextureRect.texture = load("res://Images/8.png")
	else:
		$TextureRect.texture = load("res://Images/14.png")
