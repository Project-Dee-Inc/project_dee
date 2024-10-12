extends Node3D

var active_weapons:Dictionary = {}
var active_skills:Array[BaseSkill] = []
var enable_active_skill:bool = true

func _ready():
	_subscribe()
	_init_weapons()

func _subscribe():
	EventManager.add_listener(str(EventManager.EVENT_NAMES.ON_ENABLE_SKILL_INPUT),self,"_enable_skill_input")

func _init_weapons():
	active_weapons.clear()
	active_skills.clear()

	for weapon in get_children():
		active_weapons[weapon.name] = weapon
		active_skills.append(weapon.get_node("WeaponActiveSkill"))

func _enable_skill_input(param:Array):
	enable_active_skill = param[0]

func _process(delta):
	if(enable_active_skill):
		_handle_skill_input()

func _handle_skill_input():
	if (Input.is_action_just_pressed("Skill1")):
		_cast_skill(0)
	if (Input.is_action_just_pressed("Skill2")):
		_cast_skill(1)
	if (Input.is_action_just_pressed("Skill3")):
		_cast_skill(2)
	if (Input.is_action_just_pressed("Skill4")):
		_cast_skill(3)

func _cast_skill(index:int):
	if(index < active_skills.size()):
		print("CASTING SKILL NUMBER ", index)
		active_skills[index]._activate_skill()
