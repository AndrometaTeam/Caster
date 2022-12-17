extends Node2D

onready var map = $Nav/MapSet
onready var player_spawn = $PlayerSpawn

onready var player: KinematicBody2D

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
		get_tree().change_scene("res://Scenes/ObjectScenes/Messages/Core Error.tscn")
#	load_tileset_data()

func load_data(level_data: Dictionary) -> bool:
	var tileset :TileSet
	var file_check: File = File.new()
	
	if (level_data.size() < 1):
		return false
	else:
		var tileset_location = level_path + level_data.tile_set
		print(tileset_location)
		
		if (file_check.file_exists(tileset_location)):
			map.tile_set = ResourceLoader.load(tileset_location)
			player_spawn.global_position = str2var(level_data.player_spawn)
			player.global_position = player_spawn.global_position
			return true
		else:
			print("TileSet data failed to load...")
			return false


func load_level() -> Dictionary:
	var f := File.new() # Creates a new file object.
#	f.open_encrypted_with_pass("res://Saves/save.json", File.READ, Encryption.get_key())
	f.open(level_path + level_name + ".json", File.READ) # Opens a file
	var result := JSON.parse(f.get_as_text()) # Gets the data inside of the file and parses it.
	f.close() # Closes the file
	
	if (result.error != OK): # Checks whether the file was parsed properly and isn't corrupt.
		printerr("Failed to parse map data...")
	elif (typeof(result.result) == TYPE_DICTIONARY): # Checks to make sure the data parse is a dictionary.
		print("Map successfully parsed.")
		load_level_map() # Seeing that he variable data was loaded, we can now load the map.
		return result.result as Dictionary # Returns the data after loading the map.
	else: # Something went wrong....
		push_error("Parsing failed...")
	return {}

func load_level_map(): # This loads the map from a file.
	var packed_scene = load(level_path + level_name + ".tscn") # This get's the map as a packed scene.
	var instanced_scene = packed_scene.instance() # "Unpacks" scene or rather instances it.
	
	var scene_handler = $Features/SceneInstances # Sets the father of the scene.
	
	Globals._validate_maphook(instanced_scene)
	
	scene_handler.add_child(instanced_scene) # Adds the instance to the father.
	
	var loaded_tilemap : TileMap = instanced_scene # Loads the tilemap from the instanced scene.
	var all_cells_zero_tiles = loaded_tilemap.get_used_cells() # Get's all cells by their Vector2 positions and stores them.
	
	for i in all_cells_zero_tiles: # Loops through all Vector2's in the array.
		map.set_cellv(i, loaded_tilemap.get_cellv(i)) # Set's the currently selected cell in the for loop as the map by their ID's and cell positions.
	
	instanced_scene.free() # Free's the instanced scene so it won't take any memory to keep.
#	$TileMap = scene_handler.get_node("Level2").get_node("TileMap")
#	get_tree().current_scene.print_tree()

func set_level_vars():
	level_name = GameData.level_selected
	level_path = GameData.levels_path + level_name + "/"
