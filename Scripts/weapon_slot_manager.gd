extends Node

# Array of Panel nodes for skill bars, draggable from the scene into the inspector.
@export var skill_bars: Array[Skill_Icon_Manager] = []
# Exported variable to set the default number of slots in the editor.
@export var default_number_of_slots: int = 4
# List of weapons equiped.
var weapons: Array = [] 


func _init():
	# Function to initialize the weapons array, setting its size based on the skill_bars array or a default value if skill_bars is null.
	_initialize_weapons_array()
	EventManager.add_listener(str(EventManager.EVENT_NAMES.ON_WEAPON_EQUIP), self, "_equip_weapon_listener")
	EventManager.add_listener(str(EventManager.EVENT_NAMES.ON_WEAPON_UNEQUIP), self, "_unequip_weapon_listener")
	
func _exit_tree():
	EventManager.remove_listener(str(EventManager.EVENT_NAMES.ON_WEAPON_EQUIP), self, "_equip_weapon_listener")
	EventManager.remove_listener(str(EventManager.EVENT_NAMES.ON_WEAPON_UNEQUIP), self, "_unequip_weapon_listener")

# Equip a weapon.
# Paramters:
# - weapon_instance: The weapon instance to equip.
# - slot: The slot index where the weapon should be equipped.
func _equip_weapon_listener(_params):
	# Get the weapon instance from parameters
	var instance = _params[0]
	# Initialize the slot variable to hold the index of the first empty slot (-1 indicates not found)
	var slot = -1
	# Loop through the weapons array to find the first empty slot
	for i in range(weapons.size()):
		# Check if the current slot is empty
		if weapons[i] == null:
			# Set the slot variable to the index of the empty slot
			slot = i
			# Exit the loop as we've found an empty slot
			break
	# Check if a valid empty slot was found
	if slot == -1:
		print("choose a slot")
	else:
		# Equip the weapon in the identified empty slot
		_equip_weapon(instance, slot)

# Equips a weapon in the specified slot of the skill bar.
# @param weapon_instance: The weapon to be equipped.
# @param slot: The index of the slot in which to equip the weapon.
func _equip_weapon(weapon_instance, slot: int):
	# Check if the slot index is within the valid range of skill bars
	if(slot >= 0 and slot < weapons.size()):
		# If the slot is empty (no weapon equipped), equip the weapon
		if(weapons[slot] == null):
			# Assign the weapon instance to the specified slot
			weapons[slot] = weapon_instance
			# Add the weapon instance as a child to the skill bar's parent node
			add_child(weapon_instance)
			# Check if the skill_bars array is not null.
			if skill_bars != null:
				# Store a reference to the equipped weapon in the skill bar
				skill_bars[slot]._slot_weapon(weapon_instance)
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
func _unequip_weapon_listener(_params):
	# Retrieve the slot index from the parameters
	var slot = _params[1]
	# Call the unequip_weapon function with the specified slot
	_unequip_weapon(slot)
# Unequips a weapon from the specified slot.
# @param slot: The slot index of the weapon to unequip.
func _unequip_weapon(slot: int):
	# Check if the slot index is within the valid range of skill bars
	if(slot >= 0 and slot < weapons.size()):
		# If the specified slot contains a weapon, proceed to unequip it
		if(weapons[slot] != null):
			# Return the weapon to the pool using its name
			Pool_Manager._return_weapon(weapons[slot].name, weapons[slot])
			# Set the weapons array slot to null (unequipped)
			weapons[slot] = null
			# Check if the skill_bars array is not null.
			if skill_bars != null:
				# Clear the reference from the skill bar
				skill_bars[slot]._unslot_weapon()
		else:
			# Inform that the specified slot is already empty
			print("Slot %d is already empty." % slot)
	else:
		# Print an error message for an invalid slot index
		print("Invalid slot index");

# Function to initialize the weapons array.
func _initialize_weapons_array():
	# Check if the skill_bars array is not null.
	if skill_bars != null:
		# If skill_bars exists, resize the weapons array to match the size of skill_bars.
		weapons.resize(skill_bars.size())
	else:
		# If skill_bars is null, resize the weapons array to a default number of slots (defined by default_number_of_slots).
		weapons.resize(default_number_of_slots)
