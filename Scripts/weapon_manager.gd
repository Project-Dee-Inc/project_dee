extends Node

# List of weapons equiped.
var weapons: Array = [] 
var weapons_size:int = 4

func _init():
	# Initialize weapons slots
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
	# Get the weapon instance from parameters
	var instance = _params[0]
	# Initialize the slot variable to hold the first empty slot index
	var slot = 0
	# Loop through the weapons array to find the first empty slot
	for i in range(weapons.size()):
		# Check if the current slot is empty
		if weapons[i] == null:
			# Set the slot variable to the index of the empty slot
			slot = i
			# Exit the loop as we've found an empty slot
			break
	# Check if the slot variable is still 0
	if slot == 0:
		print("choose a slot")
	else:
		# Equip the weapon in the identified empty slot
		equip_weapon(instance, slot)
		_update_weapons_list()

# Equips a weapon in the specified slot of the skill bar.
# @param weapon_instance: The weapon to be equipped.
# @param slot: The index of the slot in which to equip the weapon.
func equip_weapon(weapon_instance, slot: int):
	# Check if the slot index is within the valid range of skill bars
	if(slot >= 0 and slot < weapons_size):
		# If the slot is empty (no weapon equipped), equip the weapon
		if(weapons[slot] == null):
			# Assign the weapon instance to the specified slot
			weapons[slot] = weapon_instance
			# Print a message indicating the weapon has been equipped successfully
			print("Equipping %s on slot %d" % [weapon_instance.name, slot])
			print("Damage = %d" % weapon_instance.damage)
		else:
			# Inform that the specified slot is already occupied by another weapon
			print("Slot %d is already occupied." % slot)
	else:
		# Print an error message for an invalid slot index
		print("Invalid slot index")

# Listener function for unequipping a weapon based on parameters.
# @param _params: Array containing parameters, where the second element is the slot index.
func unequip_weapon_listener(_params):
	# Retrieve the slot index from the parameters
	var slot = _params[1]
	# Call the unequip_weapon function with the specified slot
	unequip_weapon(slot)
	_update_weapons_list()
# Unequips a weapon from the specified slot.
# @param slot: The slot index of the weapon to unequip.
func unequip_weapon(slot: int):
	# Check if the slot index is within the valid range of skill bars
	if(slot >= 0 and slot < weapons_size):
		# If the specified slot contains a weapon, proceed to unequip it
		if(weapons[slot] != null):
			# Return the weapon to the pool using its name
			Pool_Manager._return_weapon(weapons[slot].name, weapons[slot])
			# Set the weapons array slot to null (unequipped)
			weapons[slot] = null
		else:
			# Inform that the specified slot is already empty
			print("Slot %d is already empty." % slot)
	else:
		# Print an error message for an invalid slot index
		print("Invalid slot index");

func _update_weapons_list():
	EventManager.raise_event(str(EventManager.EVENT_NAMES.ON_ACTIVE_WEAPON_UPDATE), [weapons])
