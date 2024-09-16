extends Node

@export var max_slots: int = 5 # Maximum equipped weapons.
var weapons: Array = [] # List of weapons equiped.

func _init():
	# Initialize weapons slots
	weapons.resize(max_slots)
	EventManager.add_listener(str(EventManager.EVENT_NAMES.ON_WEAPON_EQUIP), self, "equip_weapon_listener")
	EventManager.add_listener(str(EventManager.EVENT_NAMES.ON_WEAPON_UNEQUIP), self, "unequip_weapon_listener")
	
func _exit_tree():
	EventManager.remove_listener(str(EventManager.EVENT_NAMES.ON_WEAPON_EQUIP), self, "equip_weapon_listener")
	EventManager.remove_listener(str(EventManager.EVENT_NAMES.ON_WEAPON_UNEQUIP), self, "unequip_weapon_listener")

# Equip a weapon.
# Paramters:
# - weapon_instance: The weapon instance to equip.
# - slot: The slot index where the weapon should be equipped.
func equip_weapon_listener(_params):
	var instance = _params[0]
	var slot = _params[1]
	equip_weapon(instance, slot)
func equip_weapon(weapon_instance, slot: int):
	if(slot >= 0 and slot < max_slots):
		if(weapons[slot] == null):
			weapons[slot] = weapon_instance
			print("Equipping %s on slot %d" % [weapon_instance.name, slot])
			print("Damage = %d" % weapon_instance.damage)
		else:
			print("Slot %d is already occupied." % slot)
	else:
		print("Invalid slot index")

# Unequip a weapon.
# Paramters:
# - slot: The slot index of the weapon to unequip.
func unequip_weapon_listener(_params):
	var slot = _params[1]
	unequip_weapon(slot)
func unequip_weapon(slot: int):
	if(slot >= 0 and slot < max_slots):
		if(weapons[slot] != null):
			weapons[slot] = null
		else:
			print("Slot %d is already empty." % slot)
	else:
		print("Invalid slot index");
