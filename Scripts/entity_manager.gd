extends Node

@onready var animation_component = $AnimationComponent
@onready var movement_component = $MovementComponent
@onready var health_component = $HealthComponent
@onready var stat_components = $StatComponents

@export var isPlayer: bool = false

func _ready():
	if(isPlayer):
		EventManager.add_listener(str(EventManager.EVENT_NAMES.ON_START_GAME),self,"_assign_values")
	else:
		_assign_values()

func _assign_values():
	#print("Assigning values")
	var base_stat = stat_components.get_child(0)
	if(base_stat!=null):
		_assign_health(base_stat)
		_assign_movement(base_stat)
	else:
		print("Base stat not found")

func _assign_movement(child:Node):
	if(movement_component != null):
		var index = Constants.get_enum_name_by_value(Constants.STATS.MOVE_SPD)
		if(child.stat_dict.has(index)):
			movement_component._set_speed(child.stat_dict[index])

func _assign_health(child:Node):
	#print("Assigning Health")
	if(health_component != null):
		#print("Health Component found")
		var index = Constants.get_enum_name_by_value(Constants.STATS.HP)
		if (child.stat_dict.has(index)):
			#print("index exists")
			health_component._set_health(child.stat_dict[index])
