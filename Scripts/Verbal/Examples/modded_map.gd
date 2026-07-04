extends Node



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
	pass
	# Globals._return_to_menu() # Use this function to return to the main menu.
		
func _recover(): # Call this when you run into an unrecoverable error, such as a critical file not found or sudden value change.
	Globals._recover_to_menu()


# Note this is an important file to protect your map / mod, to ensure for proper security, call a different script for modding. If you are knowledgable in security, you're always free to improve.
