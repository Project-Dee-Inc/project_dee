extends Node

@export var max_slots: int = 5 # Maximum equipped weapons.
var weapons: Array = [] # List of weapons equiped.

func _init():
	# Initialize weapons slots
	weapons.resize(max_slots)

# Equip a weapon.
# Paramters:
# - weapon_instance: The weapon instance to equip.
# - slot: The slot index where the weapon should be equipped.
func equip_weapon(weapon_instance, slot: int):
	if(slot >= 0 and slot < max_slots):
		if(weapons[slot] == null):
			weapons[slot] = weapon_instance
		else:
			print("Slot %d is already occupied." % slot)
	else:
		print("Invalid slot index")

# Unequip a weapon.
# Paramters:
# - slot: The slot index of the weapon to unequip.
func unequip_weapon(slot: int):
	if(slot >= 0 and slot < max_slots):
		if(weapons[slot] != null):
			weapons[slot] = null
		else:
			print("Slot %d is already empty." % slot)
	else:
		print("Invalid slot index");
