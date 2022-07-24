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
	load_data(load_level())


func load_data(level_data: Dictionary):
	var tileset :TileSet
	var file_check: File = File.new()
	
	print(level_data.tile_set)
	if (file_check.file_exists(level_data.tile_set)):
		tileset = ResourceLoader.load(level_data.tile_set)
		map.tile_set = tileset
	
	player_spawn.global_position = str2var(level_data.player_spawn)
	player.global_position = player_spawn.global_position

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
	
	var scene_handler = $Features/SceneInstances # Sets the father of the scene
	
	scene_handler.add_child(instanced_scene) # Adds the instance to the father.
	
	var loaded_tilemap : TileMap = instanced_scene # Loads the tilemap from the instanced scene.
#	var all_tiles_zero_cells = loaded_tilemap.get_used_cells_by_id(0) # Gets all used cells by their respective tile indexs.
	var all_cells_zero_tiles = loaded_tilemap.get_used_cells() # Get's all cells by their Vector2 positions and stores them.
	
	
	for i in all_cells_zero_tiles: # Loops through all Vector2's in the array.
		map.set_cellv(i, loaded_tilemap.get_cellv(i)) # Set's the currently selected cell in the for loop as the map by their ID's and cell positions.

	instanced_scene.free() # Free's the instanced scene so it won't take any memory to keep.
#	$TileMap = scene_handler.get_node("Level2").get_node("TileMap")
#	get_tree().current_scene.print_tree()

func set_level_vars():
	level_name = GameData.level_selected
	level_path = GameData.levels_path + level_name + "/"
