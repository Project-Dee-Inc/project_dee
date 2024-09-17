extends Panel

var item = null
@onready var inventory: Node2D = $"../.."

func _ready():
	pass
		
func _pick_item():
	remove_child(item)
	inventory.add_child(item)
	item = null
	
func _drop_item(new_item):
	item = new_item
	item.position = Vector2(0, 0)
	if item.get_parent() == inventory:
		inventory.remove_child(item)
	add_child(item)
