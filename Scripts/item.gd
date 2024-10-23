extends Node2D

@export var item_name: String
@onready var quantity: Label = $TextureRect/Quantity
@export var item_quantity: int = 1
		
func _display_item_icon(display_name: String, image: Texture2D):
	item_name = display_name
	$TextureRect.texture = image

func _increment():
	item_quantity += 1
	quantity.text = str(item_quantity)

func _decrement():
	if item_quantity > 1:
		item_quantity -= 1
	if item_quantity == 1:
		quantity.text = ""
	else:
		quantity.text = str(item_quantity)
