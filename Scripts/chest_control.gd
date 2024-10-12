extends Area3D
class_name ChestControl

@export var mimic_scene: PackedScene
@onready var stat_component: StatComponent = $StatComponent
@onready var animated_sprite: AnimatedSprite3D = $AnimatedSprite3D

var mimic_chance:float 
var gold:int = 0
var item:PackedScene

func _ready():
	_set_values()

func _set_values():
	gold = stat_component.stat_dict[Constants.get_enum_name_by_value(Constants.STATS.GOLD_GAIN)]
	mimic_chance = stat_component.stat_dict[Constants.get_enum_name_by_value(Constants.STATS.RNG)]

func _is_mimic():
	var rng = randi() % 100  # Generates a random number between 0 and 99
	if (rng < mimic_chance):
		return true  
	else:
		return false  

func _open_chest():
	animated_sprite.play("open")

func _spawn_chest():
	EventManager.raise_event(str(EventManager.EVENT_NAMES.ON_GAIN_GOLD), [gold])

func _spawn_mimic():
	var instance = mimic_scene.instantiate()

	var root_node = get_tree().current_scene
	root_node.add_child(instance)

	instance._set_values(self.global_transform.origin)

func _on_body_entered(body: Node3D) -> void:
	if(body.is_in_group("player")):
		_open_chest()
		await get_tree().create_timer(0.8).timeout

		if(_is_mimic()):
			_spawn_mimic()
		else:
			_spawn_chest()

		queue_free()
