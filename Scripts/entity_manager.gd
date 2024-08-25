extends CharacterBody3D

@onready var animation_component = $AnimationComponent
@onready var movement_component = $MovementComponent
@onready var health_component = $HealthComponent
@onready var stat_components = $StatComponents

@export var isPlayer: bool = false

func _ready():
	if(isPlayer):
		EventManager.add_listener(str(EventManager.EVENT_NAMES.ON_START_GAME),self,"_assign_values")
	else:
		_assign_values(null)

func _assign_values(_params):
	var base_stat = stat_components.get_child(0)
	if(base_stat!=null):
		_assign_health(base_stat)
		_assign_movement(base_stat)
	else:
		print("Base stat not found")

	if(isPlayer):
		print("STARTING PLAYER INITIALIZATION")
		EventManager.raise_event(str(EventManager.EVENT_NAMES.ON_PLAYER_INITIALIZED))

func _assign_movement(child:Node):
	if(movement_component != null):
		#movement_component.player_component = self
		var index = Constants.get_enum_name_by_value(Constants.STATS.MOVE_SPD)
		if(child.stat_dict.has(index)):
			movement_component._set_speed(child.stat_dict[index])

func _assign_health(child:Node):
	if(health_component != null):
		if(isPlayer):
			health_component._set_is_player()

		var hpIndex = Constants.get_enum_name_by_value(Constants.STATS.HP)
		if (child.stat_dict.has(hpIndex)):
			health_component._set_health(child.stat_dict[hpIndex])

		var regenIndex = Constants.get_enum_name_by_value(Constants.STATS.HP_REGEN)
		if (child.stat_dict.has(regenIndex) && child.stat_dict[regenIndex] > 0):
			health_component._set_regen(child.stat_dict[regenIndex])

