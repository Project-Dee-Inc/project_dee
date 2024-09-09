extends Panel

var item_class = preload("res://Scenes/item.tscn")
var item = null
@onready var inventory: Node2D = $"../.."

func _ready():
	if randi() % 2 == 0:
		item = item_class.instantiate()
		add_child(item)
		
func _pick_item():
	remove_child(item)
	inventory.add_child(item)
	item = null
	
func _drop_item(new_item):
	item = new_item
	item.position = Vector2(0, 0)
	inventory.remove_child(item)
	add_child(item)
