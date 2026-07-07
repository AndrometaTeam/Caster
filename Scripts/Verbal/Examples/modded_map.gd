extends Node

var map_id: int
var map_version: String
var min_game_version: int
var game_version: int

var mods: Array[Node] # Store the mods here for future reference.

# Called when the node enters the scene tree for the first time.
# Format = (MinGameVersion, GameVersion, HookingFeatures)
#     	   (String, String, Boolean)
func _validate_level() -> Array:
	return [025, 0252, false]

# I recommend leaving this part of the function alone to ensure game-mod security.
# If your hooking features are enabled, this check will ensure the mod is ran from a valid client.
func _ready(): 
	if !(Globals.has_method("_return_to_menu") && Globals.has_method("_validate_maphook")):
		get_tree().quit(1)
	
	# Your code here. \/
	Cmdk._init_mdk(self)
	
	# Globals._return_to_menu() # Use this function to return to the main menu.
	

func _player_hook(player):
	pass # Hook the player here.

## As each mod is instanced this runs for every one. Mods are considered features. Map creators have the power to blacklist/whitelist mods from loading on their map!
func _mod_hook(mod): # This will be called every iteration during mod loading, this allows you to block a specific mod from loading or reference the mod's data.
	pass # in cmdk I plan to add a mod loader for feature based mods.
		 # this will loop through each mod once cmdk init has called.
		 # and that will allow you to get the data from mods here.

func _recover(): # Call this when you run into an unrecoverable error, such as a critical file not found or sudden value change.
	Globals._recover_to_menu()

# Note this is an important file to protect your map / mod, to ensure for proper security, call a different script for modding. If you are knowledgable in security, you're always free to improve.
