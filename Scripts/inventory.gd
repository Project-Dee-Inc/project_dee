extends Node2D

const slot_class = preload("res://Scripts/slot.gd")
@onready var grid_container: GridContainer = $GridContainer
var selected_item = null
var added_items = []

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
				
func _input(_event):
	if selected_item:
		selected_item.global_position = get_global_mouse_position()
		
func _store_item(item):
	var item_name = item.item_name
	if _check_for_item_dup(item_name):
		return
	for inv_slot in grid_container.get_children():
		if !inv_slot.item:
			inv_slot._drop_item(item)
			added_items.append(item)
			break
			
func _check_for_item_dup(name: String) -> bool:
	for existing_item in added_items:
		if existing_item.item_name == name:
			existing_item._increment()
			return true
	return false
