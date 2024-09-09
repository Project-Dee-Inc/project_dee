extends Node2D

const slot_class = preload("res://Scripts/slot.gd")
@onready var grid_container: GridContainer = $GridContainer
var selected_item = null

func _ready():
	for inv_slot in grid_container.get_children():
		inv_slot.connect("gui_input", Callable(self, "_slot_gui_input").bind(inv_slot))
		
func _slot_gui_input(event: InputEvent, slot: slot_class):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
			if selected_item != null:
				if !slot.item:
					slot._drop_item(selected_item)
					selected_item = null
				else:
					var temp_item = slot.item
					slot._pick_item()
					temp_item.global_position = event.global_position
					slot._drop_item(selected_item)
					selected_item = temp_item
			elif slot.item:
				selected_item = slot.item
				slot._pick_item()
				selected_item.global_position = get_global_mouse_position()
				
func _input(event):
	if selected_item:
		selected_item.global_position = get_global_mouse_position()
