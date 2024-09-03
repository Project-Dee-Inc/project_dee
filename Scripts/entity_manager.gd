extends CharacterBody3D

@onready var animation_component = $AnimationComponent
@onready var movement_component = $MovementComponent
@onready var health_component = $HealthComponent
@onready var stat_components = $StatComponents

@export var isPlayer: bool = false
var player_initialized:bool = false

func _ready():
	if(isPlayer):
		EventManager.add_listener(str(EventManager.EVENT_NAMES.ON_START_GAME),self,"_start_assigning_values")
		EventManager.add_listener(str(EventManager.EVENT_NAMES.ON_END_GAME),self,"_game_ended")
	else:
		_start_assigning_values(null)

func _game_ended():
	player_initialized = false

func _reassign_values(new_stat_dict:Dictionary):
	_assign_values(new_stat_dict)

func _start_assigning_values(_params):
	_assign_values(stat_components.get_child(0).stat_dict)

func _assign_values(base_stat_dict:Dictionary):
	if(base_stat_dict!=null):
		_assign_health(base_stat_dict)
		_assign_regen_health(base_stat_dict)
		_assign_movement(base_stat_dict)
	else:
		print("Base stat not found")

	if(isPlayer && !player_initialized):
		print("STARTING PLAYER INITIALIZATION")
		EventManager.raise_event(str(EventManager.EVENT_NAMES.ON_PLAYER_INITIALIZED))
		player_initialized = true

func _assign_movement(base_stat_dict:Dictionary):
	if(movement_component != null):
		var moveIndex = Constants.get_enum_name_by_value(Constants.STATS.MOVE_SPD)
		if(base_stat_dict.has(moveIndex) && movement_component.speed != base_stat_dict[moveIndex]):
			movement_component._set_speed(base_stat_dict[moveIndex])

func _assign_health(base_stat_dict:Dictionary):
	if(health_component != null):
		if(isPlayer):
			health_component._set_is_player()

		var hpIndex = Constants.get_enum_name_by_value(Constants.STATS.HP)
		if (base_stat_dict.has(hpIndex) && health_component.max_health != base_stat_dict[hpIndex]):
			if(health_component.max_health != 0):
				var added_health = health_component.max_health - base_stat_dict[hpIndex]
				health_component._update_health(added_health)
			else:
				health_component._set_health(base_stat_dict[hpIndex])

func _assign_regen_health(base_stat_dict:Dictionary):
	if(health_component != null):
		var regenIndex = Constants.get_enum_name_by_value(Constants.STATS.HP_REGEN)
		if (base_stat_dict.has(regenIndex) && base_stat_dict[regenIndex] > 0 && health_component.hp_regen != base_stat_dict[regenIndex]):
			health_component._set_regen(base_stat_dict[regenIndex])
