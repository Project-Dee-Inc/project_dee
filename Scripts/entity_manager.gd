extends Node

@onready var animation_component = $AnimationComponent
@onready var movement_component = $MovementComponent
@onready var health_component = $HealthComponent
@onready var stat_components = $StatComponents

@export var isPlayer: bool = false

func _ready():
	if(isPlayer):
		EventManager.add_listener(str(EventManager.EVENT_NAMES.ON_START_GAME),self,"_assign_health")
	else:
		_assign_health()

func _assign_health():
	if(health_component != null):
		health_component._set_health(stat_components.get_child(1).stat_dict[4])


