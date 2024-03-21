extends Node2D

@onready var map = $Nav/MapSet
@onready var player_spawn = $PlayerSpawn

@onready var player: CharacterBody2D

var level_name: String
var level_path: String

func _ready():
#	map = str2var(LevelData.map_data)
#	player_spawn = str2var(LevelData.player_spawn)
#	print(player_spawn)
#	player.global_position.x = player_spawn.x
#	player.global_position.y = player_spawn.y

	
	set_level_vars()
#	load_data(load_level())
	if (!load_data(load_level())):
		queue_free()
		get_tree().change_scene_to_file("res://Scenes/ObjectScenes/Messages/Core Error.tscn")
#	load_tileset_data()


# This function can be modified to be wrapped by a different base game, you could literally copy-paste this and it would work with some tweaks.
func load_data(level_data: Dictionary) -> bool: # Needs documentation. # Functionally, if you're designing your own game and you're just stripping my system, you should load it your own way with your own scene info.
	var tileset: TileSet
	

	if (level_data.size() < 1):
		print("TileSet doesn't exist?")
		return false
	else:
		var tileset_location = level_path + level_data.tile_set
		print(tileset_location)
		
		
		if (FileAccess.file_exists(tileset_location)):
			print(map.get_layers_count())
			map.tile_set = ResourceLoader.load(tileset_location)
			player_spawn.global_position = str_to_var(level_data.player_spawn)
			player.global_position = player_spawn.global_position
			return true
		else:
			print("TileSet data failed to load...")
			return false


func load_level() -> Dictionary:
	var f := FileAccess.open(level_path + level_name + ".json", FileAccess.READ) # Creates a new file object.
#	f.open_encrypted_with_pass("res://Saves/save.json", File.READ, Encryption.get_key())
	# Opens a file
	var test_json_conv = JSON.new()
	
	var result = test_json_conv.parse(f.get_as_text()) # Gets the data inside of the file and parses it.#test_json_conv.get_data()
	f.close() # Closes the file
	
	if (result != OK): # Checks whether the file was parsed properly and isn't corrupt.
		printerr("Failed to parse map data...")
	elif (typeof(test_json_conv.get_data()) == TYPE_DICTIONARY): # Checks to make sure the data parse is a dictionary.
		load_level_map() # Seeing that the variable data was loaded, we can now load the map.
		print("Map successfully parsed.")
		return test_json_conv.get_data() as Dictionary # Returns the data after loading the map.
	else: # Something went wrong....
		push_error("Parsing failed...")
	return {}

func load_level_map(): # This loads the map from a file.
	var packed_scene = load(level_path + level_name + ".tscn") # This get's the map as a packed scene.
	var instanced_scene = packed_scene.instantiate() # "Unpacks" scene or rather instances it.

	Globals._validate_maphook(instanced_scene) # This validates the map / mod instance.
	
	var scene_handler = $Features/SceneInstances # Sets the father of the scene.
	scene_handler.add_child(instanced_scene) # Adds the instance to the father.
	
	var loaded_tilemap : TileMap = instanced_scene # Loads the tilemap from the instanced scene.
	var all_cells_zero_tiles = loaded_tilemap.get_used_cells(0) # Get's all cells by their Vector2 positions and stores them.

	
	for i in all_cells_zero_tiles: # Loops through all Vector2's in the array.
		map.set_cell(0, Vector2i.ZERO, loaded_tilemap.get_cell_source_id(0, i), Vector2i.ZERO) # Set's the currently selected cell in the for loop as the map by their ID's and cell positions.
	# get_cellv(i)
	instanced_scene.free() # Free's the instanced scene so it won't take any memory to keep.
#	$TileMap = scene_handler.get_node("Level2").get_node("TileMap")
#	get_tree().current_scene.print_tree()

func set_level_vars():
	level_name = GameData.level_selected
	level_path = GameData.levels_path + level_name + "/"
