extends Node2D

@export var map: TileMapLayer
@onready var player_spawn: Marker2D = $PlayerSpawn

@onready var player: CharacterBody2D

signal level_loaded_complete

var level_name: String
var level_path: String

func _ready():
	player.global_position = player_spawn.position

	set_level_vars()

	if !level_name == "dev":
		if (!load_data(load_level())):
			queue_free()
			get_tree().change_scene_to_file("res://Scenes/ObjectScenes/Messages/Core Error.tscn")

	



# This function can be modified to be wrapped by a different base game, you could literally copy-paste this and it would work with some tweaks.
func load_data(level_data: Dictionary) -> bool: # Needs documentation. # Functionally, if you're designing your own game and you're just stripping my system, you should load it your own way with your own scene info.
	var tileset: TileSet
	var file_check: FileAccess
	
	if (level_data.size() < 1):
		print("No level data found...")
		print(level_data)
		return false
	else:
		var tileset_location = level_path + level_data.tile_set
		print(tileset_location)
		if (FileAccess.file_exists(tileset_location)):
			map.tile_set = ResourceLoader.load(tileset_location)
			player_spawn.global_position = str_to_var(level_data.player_spawn)
			player.global_position = player_spawn.global_position
			return true
		else:
			print("TileSet data failed to load...")
			return false


func load_level() -> Dictionary:
	var path = level_path + level_name + ".json"
	print(path)
	var file := FileAccess.open(path, FileAccess.READ) # Opens a file
#	f.open_encrypted_with_pass("res://Saves/save.json", File.READ, Encryption.get_key())
	var json := JSON.new()
	var data : Variant = json.parse_string(file.get_as_text()) # Gets the data inside of the file and parses it.
	file.close() # Closes the file
	
	if (data == null): # Checks whether the file was parsed properly and isn't corrupt.
		push_error("Failed to parse map data (error %s) in: %s" % [data, path])
		return {}
	if typeof(data) != TYPE_DICTIONARY:
		push_error("Top-level JSON is not a Dictionary in: %s" % path)
		return {}
	print(data)
	load_level_map()
	return data

func load_level_map(): # This loads the map from a file.
	print("LOADING: " + level_path + level_name + ".tscn")
	var packed_scene: PackedScene = load(level_path + level_name + ".tscn") # This get's the map as a packed scene.
	var instanced_scene = packed_scene.instantiate() # "Unpacks" scene or rather instances it.

	Globals._validate_maphook(instanced_scene) # This validates the map / mod instance.
	
	var scene_handler = $Features/SceneInstances # Sets the parent of the scene.
	if scene_handler == null: # Ensures there is a parent to work with.
		var NewNode = Node2D.new()
		NewNode.name = "SceneInstances"
		$Features.add_child(NewNode)
		scene_handler = NewNode
	scene_handler.add_child(instanced_scene) # Adds the instance to the father.
	
	var loaded_tilemap : TileMapLayer = instanced_scene # Loads the tilemap from the instanced scene.
	var all_cells_zero_tiles = loaded_tilemap.get_used_cells() # Get's all cells by their Vector2 positions and stores them.
	
	#for i in all_cells_zero_tiles: # Loops through all Vector2's in the array.
		#map.set_cellv(i, loaded_tilemap.get_cellv(i)) # Set's the currently selected cell in the for loop as the map by their ID's and cell positions.
	map.tile_map_data = loaded_tilemap.tile_map_data
	print(loaded_tilemap.tile_map_data)
	

	
	#instanced_scene.free() # Free's the instanced scene so it won't take any memory to keep.
#	$TileMap = scene_handler.get_node("Level2").get_node("TileMap")
#	get_tree().current_scene.print_tree()

func set_level_vars():
	level_name = GameData.level_selected
	level_path = GameData.levels_path + level_name + "/"
	print(level_path)
