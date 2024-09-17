extends Node2D

@export var item_name: String
		
func _display_item_icon(name: String, image: Texture2D):
	item_name = name
	$TextureRect.texture = image
