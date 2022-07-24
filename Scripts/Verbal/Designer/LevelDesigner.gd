extends Node2D

# To be documented

# All variables that are references to ther elements
onready var LevelDesigner : Node2D = $LevelDesignerElements
onready var HUD : CanvasLayer = $LevelDesignerElements/HUD

onready var map : TileMap = $TileMap
onready var selector : Sprite = $selector
onready var player_spawn_selector : Sprite = $player_spawn
onready var snap_size : Vector2 = selector.snap_size
onready var tile_ids : Array

# Logic variables
var tile_max_id : int = 0
var selected_id : int = 0
var skip_input_check : bool = false

# Data variables
var player_spawn : Vector2 = Vector2(10, 10)
#var save_dict : Dictionary = {}

var level_name : String = "no-name" 
var level_path : String = GameData.levels_path + level_name + "/"

func _ready():
	HUD.connect("focus_changed", self, "_on_UI_focus_changed")
	HUD.connect("level_name_changed", self, "change_level_name")
	
	# Eventually when this editior is completely finished
	# I plan to automatically load whatever scene is selected
	# in the GameData singleton. This should be useful in keeping
	# things nicely together across sessions.
	
	# This checks if the selected level is anything but no-level.
	if !(GameData.level_selected == "no-level"):
		change_level_name(GameData.level_selected)
		load_data(load_level())

	load_tileset_data()
	player_spawn_selector.position = player_spawn


func _physics_process(delta):
	if (!skip_input_check):
		if (Input.is_action_just_pressed("ui_cancel")):
			print(level_name)
			get_tree().quit()
		
		if (Input.is_action_just_pressed("interact")):
			save_level(save_data())
		
		if (Input.is_action_just_pressed("builder_load_level")):
			var level = load_level() # Get's the level data and loads the map.
			if (level.empty()): # Checks if the level loading was skipped and continues.
				print("Loading was skipped...")
			else: # Otherwise loads the pre-existing level data and tileset.
				load_data(level)
				load_tileset_data()
				
				
#				map = str2var(level.map_data) # This doesn't work properly and there is a better alternative to loading the map.

		if (Input.is_action_just_released("mouse_wheel_up")): # Changes index of tilemap.
			change_selected_tile(m_index.up)
		elif (Input.is_action_just_released("mouse_wheel_down")):
			change_selected_tile(m_index.down)

		if (Input.is_action_pressed("move_down")): # Set's the spawn of the player.
			set_player_spawn(get_global_mouse_position())
			selector.visible = false
		elif (Input.is_action_just_released("move_down")):
			selector.visible = true

		if (Input.is_action_just_pressed("designer_clear_map")):
			clear_map()

		if (Input.is_action_just_pressed("tab")): # Hides the inspector UI
			HUD.emit_signal("hide_inspector")

		if (Input.is_action_pressed("right_mouse") && selector.visible):
			var tile : Vector2 = map.world_to_map(selector.mouse_pos * snap_size.x)
			if (map.get_cellv(tile) != -1):
				map.set_cellv(tile, -1)

		# This allows you to place the currently selected tile at your mouse position
		# based on your snap size.
		if (Input.is_action_pressed("left_mouse") && selector.visible):
			var tile : Vector2 = map.world_to_map(selector.mouse_pos * snap_size.x)
			map.set_cellv(tile, selected_id)

func set_player_spawn(pos: Vector2 = Vector2(10, 10)):
	player_spawn = pos
	player_spawn_selector.position = pos

func change_selected_tile(index):
	if (index == m_index.up):
		if (selected_id < tile_max_id):
			selected_id += 1
	elif (index == m_index.down):
		if (selected_id > 0):
			selected_id -= 1
	
	if (selected_id != -1):
		HUD.set_selected_text(map.tile_set.tile_get_name(selected_id))

enum m_index {
	up,
	down
}

# Experimental features
# Experimental Vars

func save_level_scene():
	LevelDesigner.free()
	selector.free()
	player_spawn_selector.free()
#	$LevelDesignerElements/HUD/Control.visible = false
	
	if (ResourceSaver.save(level_path + "data/tileset.tres", map.tile_set) == OK):
		var packed_scene = PackedScene.new()
		packed_scene.pack(map)
		ResourceSaver.save(level_path + level_name + ".tscn", packed_scene)
		print("Level and data successfully saved...")
	else:
		print("Something went wrong saving the tile data.")
	reload_editor()

func load_level_scene(): # This loads the map from a file.
	var packed_scene = load(level_path + level_name + ".tscn") # This get's the map as a packed scene.
	var instanced_scene = packed_scene.instance() # "Unpacks" scene or rather instances it.
	
	var scene_handler = $LevelDesignerElements/SceneInstances # Sets the father of the scene
	
	scene_handler.add_child(instanced_scene) # Adds the instance to the father.
	clear_map()
	
	var loaded_tilemap : TileMap = instanced_scene # Loads the tilemap from the instanced scene.
#	var all_tiles_zero_cells = loaded_tilemap.get_used_cells_by_id(0) # Gets all used cells by their respective tile indexs.
	var all_cells_zero_tiles = loaded_tilemap.get_used_cells() # Get's all cells by their Vector2 positions and stores them.
	
	
	for i in all_cells_zero_tiles: # Loops through all Vector2's in the array.
		map.set_cellv(i, loaded_tilemap.get_cellv(i)) # Set's the currently selected cell in the for loop as the map by their ID's and cell positions.

	instanced_scene.free() # Free's the instanced scene so it won't take any memory to keep.
	print("Root (Post-load)")
	print_tree_pretty() # Prints the scene tree after it loads !!!!!!! Remove before release !!!!!!!
#	$TileMap = scene_handler.get_node("Level2").get_node("TileMap")
#	get_tree().current_scene.print_tree()

func save_level(data: Dictionary):
	var f := File.new()

	directory_builder()
	print("Building structure...")

	if (f.open(level_path + level_name + ".json", File.WRITE) == OK):
	#	f.open_encrypted_with_pass("res://Saves/save.json", File.WRITE, Encryption.get_key())
		print("Saving to ", f.get_path_absolute())
		f.store_string(JSON.print(data))
		f.close()
		save_level_scene()
	else:
		print("An error occured during the saving process.")

# This load_level function makes calls to save the variable and scene data.
# It's extremely important to load level data and is very promising.

func load_level() -> Dictionary:
	var f := File.new() # Creates a new file object.
#	f.open_encrypted_with_pass("res://Saves/save.json", File.READ, Encryption.get_key())
	f.open(level_path + level_name + ".json", File.READ) # Opens a file
	var result := JSON.parse(f.get_as_text()) # Gets the data inside of the file and parses it.
	f.close() # Closes the file
	
	if (result.error != OK): # Checks whether the file was parsed properly and isn't corrupt.
		print("Failed to parse map data...")
	elif (typeof(result.result) == TYPE_DICTIONARY): # Checks to make sure the data parse is a dictionary.
		print("Map successfully parsed.")
		load_level_scene() # Seeing that he variable data was loaded, we can now load the map.
		return result.result as Dictionary # Returns the data after loading the map.
	else: # Something went wrong....
		push_error("Parsing failed...")
	return {}

func save_data() -> Dictionary:
	var save_dict = {
				"level_name": str(level_name),
				"player_spawn": var2str(player_spawn),
				"tile_set": str(level_path) + "data/tileset.tres"
#				"map_data": var2str(map)
			}
	return save_dict

func load_data(level_data: Dictionary):
	var tileset :TileSet
	var file_check: File = File.new()
	
	if (file_check.file_exists(level_data.tile_set)):
		tileset = ResourceLoader.load(level_data.tile_set)
		map.tile_set = tileset
	
	player_spawn = str2var(level_data.player_spawn)
	player_spawn_selector.position = player_spawn

# func save_tileset_data(): # Not yet implemented.
# Plan: Using a tileset node, we should be able to create a ResourceSaver and save it
# the same way we save out the tileset data. Makes no sense right now, but will soon.

func load_tileset_data():
	tile_ids = map.tile_set.get_tiles_ids()
	tile_max_id = tile_ids.size() - 1
	change_selected_tile(m_index.down)

func change_level_name(_name: String = "no-name"):
	level_name = _name
	level_path = GameData.levels_path + level_name + "/"

func directory_builder():
	var dir = Directory.new()
	
	if (dir.dir_exists(level_path)):
		return 0
	else:
		dir.make_dir(level_path)
		dir.make_dir(level_path + "data/")

func reload_editor(): # This queues and free's the current level and loads it again to reset everything.
	queue_free()
	get_tree().change_scene("res://Scenes/Levels/LevelDesigner/LevelDesigner.tscn")
	print("Root (Post-Reload)")
	print_tree_pretty()

func clear_map():
	var all_cells_zero_tiles = map.get_used_cells() # Get's all cells by their Vector2 positions and stores them.
	
	for i in all_cells_zero_tiles: # Loops through all Vector2's in the array.
		map.set_cellv(i, -1) # Set's the currently selected cell in the for loop as the map by their ID's and cell positions.
	
	set_player_spawn()

func _on_UI_focus_changed(state: bool = true):
	skip_input_check = state
