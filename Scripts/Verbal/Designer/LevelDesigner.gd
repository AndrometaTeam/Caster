extends Node2D

# MOVE UI CODE INTO UI HANDLING SCRIPT
# DIRECT UI MODIFICATIONS SHOULDN'T EXIST HERE.

# NEW LEVELS MADE IN THE EDITOR WILL NOT LOAD IN STANDALONE LEVEL
# LOADER DUE TO COMPATIBILITY CHANGES, MIGRATE NEW SYSTEM SOON.

# ADD OBJECT PROPERTIES TAB.

# References to UI nodes
@onready var LevelDesigner: Node2D = $LevelDesignerElements
@onready var HUD: CanvasLayer = $LevelDesignerElements/HUD
@onready var objects_selector_v_box: VBoxContainer = $LevelDesignerElements/HUD/Control/ObjectSelector/objectsSelector/objectsSelectorVBox
@onready var tree_v_box: VBoxContainer = $LevelDesignerElements/HUD/Control/Ispector/VBoxContainer/Tree/treeVBox

@onready var map_layer: TileMapLayer = $MapLayer
@onready var features: Node2D = $Features

@onready var selector: Sprite2D = $selector
@onready var player_spawn_selector: Sprite2D = $player_spawn
@onready var snap_size: Vector2 = selector.snap_size

# Logic variables
var skip_input_check: bool = false
var hold_obj: bool = false
var selected_obj: Node

var tile_entries: Array = []
var selected_entry: int = 0

var features_cache: Array[PackedScene]
var selected_feature: int = 0

# Data variables
var player_spawn: Vector2 = Vector2(10, 10)
var level_name: String = "no-name" 
var level_path: String = GameData.levels_path + level_name + "/"

# UI variables
var editor_mode: int = 0
var mouse_pos: Vector2 = Vector2.ZERO

enum m_index { up, down }
enum m_mode { none, map, feature }

func _ready():
	HUD.connect("focus_changed", Callable(self, "_on_UI_focus_changed"))
	HUD.connect("level_name_changed", Callable(self, "change_level_name"))
	
	if !(GameData.level_selected == "no-level"):
		change_level_name(GameData.level_selected, true)
		load_features()
		
		if (load_data(load_level())):
			refresh_tileset_data()
			reload_tree()
		else:
			queue_free()
			get_tree().change_scene_to_file("res://Scenes/ObjectScenes/Messages/Core Error.tscn")
	else:
		load_features()
		refresh_tileset_data()
	
	# Temporary to update the selected UI.
	_unhandled_input(null)
	player_spawn_selector.position = player_spawn

func _process(_delta):
	if (!skip_input_check):
		match editor_mode:
			m_mode.none:
				pass
			m_mode.map:
				mouse_pos = map_layer.local_to_map(get_global_mouse_position())
				var selector_vector: Vector2 = map_layer.map_to_local(mouse_pos)
				selector.global_position = Vector2(selector_vector.x - 16, selector_vector.y - 16)
			m_mode.feature:
				var selector_vector: Vector2 = get_global_mouse_position()
				selector.global_position = Vector2(selector_vector.x - 16, selector_vector.y - 16)
		
		if (Input.is_action_just_pressed("ui_cancel")):
			$LevelDesignerElements/EscapeMenu.toggle_menu()
		
		if (Input.is_action_just_pressed("interact")):
			save_level(save_data())
		
		if (Input.is_action_just_pressed("builder_load_level")):
			var level = load_level() # Get's the level data and loads the map.
			if (level.is_empty()): # Checks if the level loading was skipped and continues.
				print("Loading was skipped...")
			else: # Otherwise loads the pre-existing level data and tileset.
				load_data(level)
				refresh_tileset_data() 
		
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
			match editor_mode:
				m_mode.none:
					pass
				m_mode.map:
					remove_tile()
				m_mode.feature:
					pass # Not yet implemented
		
		if (Input.is_action_pressed("left_mouse") && selector.visible):
			match editor_mode:
				m_mode.none:
					if selected_obj != null:
						hold_obj = true
				m_mode.map:
					add_tile()
				m_mode.feature:
					# later add a feature that allows picking up objects
					if selected_obj != null:
						hold_obj = true
					
					if !hold_obj:
						add_feature(selected_feature)
					else:
						selected_obj.position = get_global_mouse_position()
					
		if (Input.is_action_just_released("left_mouse")):
			match editor_mode:
				m_mode.feature:
					hold_obj = false
					selected_obj = null
			

func _unhandled_input(event) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_1:
			selector.visible = true
			editor_mode = m_mode.map
		if event.pressed and event.keycode == KEY_2:
			selector.visible = true
			editor_mode = m_mode.feature
		if event.pressed and event.keycode == KEY_3:
			selector.visible = false
			editor_mode = m_mode.none
		if event.pressed and event.keycode == KEY_DELETE and selected_obj != null:
			selected_obj.queue_free()
			reload_tree()
	
	var e = tile_entries[selected_entry]
	var src_id: int = e["source_id"]
	var atlas_coords: Vector2i = e["atlas"]
	var alt: int = e["alt"]
	
	var mode: String = "None"
	
	match editor_mode:
		m_mode.none:
			mode = "None"
		m_mode.map:
			mode = "Map"
		m_mode.feature:
			mode = "Object"
	
	HUD.set_selected_text("%s | (%d,%d) alt=%d" % [str(src_id), atlas_coords.x, atlas_coords.y, alt] + " Mode: " + mode)
	# Currently the selected text feature in the hud is a temporary measure.
	# This will be a more flushed out HUD later.

func set_player_spawn(pos: Vector2 = Vector2(10, 10)):
	player_spawn = pos
	player_spawn_selector.position = pos

func change_selected_tile(index):
	if tile_entries.size() == 0:
		return
		
	if (index == m_index.up):
		selected_entry = clampi(selected_entry + 1, 0, tile_entries.size() - 1)
	elif (index == m_index.down):
		selected_entry = clampi(selected_entry - 1, 0, tile_entries.size() - 1)
	

func save_level_scene(): # This function is being reworked to support the new format for levels.
	LevelDesigner.free()
	selector.free()
	player_spawn_selector.free()
	
	if (ResourceSaver.save(map_layer.tile_set, level_path + "data/tileset.tres") == OK):
		var packed_scene = build_tree()
		ResourceSaver.save(packed_scene, level_path + level_name + ".tscn")
		print("Level and data successfully saved...")
	else:
		print("Something went wrong saving the tile data.")
	reload_editor()

func load_level_scene(): # This function is being reworked to support the new format for levels.
	var full_path = level_path + level_name + ".tscn"
	if not ResourceLoader.exists(full_path):
		return
		
	var packed_scene: PackedScene = ResourceLoader.load(full_path)
	var instanced_scene = packed_scene.instantiate() as Node2D
	var map: TileMapLayer
	var _features: Node2D
	
	for child in instanced_scene.get_children():
		match child.name:
			"Features":
				_features = child
			"MapLayer":
				map = child
	
	if _features and map:
		clear_map()
	
		var used_cells : Array[Vector2i] = map.get_used_cells()
		for coords in used_cells:
			var src := map.get_cell_source_id(coords)
			var atlas := map.get_cell_atlas_coords(coords)
			var alt := map.get_cell_alternative_tile(coords)
			map_layer.set_cell(coords, src, atlas, alt)
	
		for child in _features.get_children():
					var new_child = child.duplicate()
					features.add_child(new_child)
					new_child.owner = features
	
	instanced_scene.free()

func save_level(data: Dictionary):
	directory_builder()
	var f := FileAccess.open(level_path + level_name + ".json", FileAccess.WRITE)
	if (f != null):
		f.store_string(JSON.stringify(data, " "))
		f.close()
		save_level_scene()
	else:
		print("An error occurred during the saving process.")

func load_level() -> Dictionary:
	var path = level_path + level_name + ".json"
	if not FileAccess.file_exists(path):
		return {}
		
	var f := FileAccess.open(path, FileAccess.READ)
	var test_json_conv = JSON.new()
	var error = test_json_conv.parse(f.get_as_text())
	f.close()
	
	if error != OK:
		printerr("Failed to parse map data...")
		return {}
		
	var result = test_json_conv.get_data()
	if (typeof(result) == TYPE_DICTIONARY):
		load_level_scene()
		return result as Dictionary
	return {}

func save_data() -> Dictionary:
	return {
		"level_name": str(level_name),
		"player_spawn": var_to_str(player_spawn),
		"tile_set": "data/tileset.tres"
	}

func load_data(level_data: Dictionary) -> bool:
	if (level_data.size() < 1 or level_data.is_empty()):
		return false
	
	var ts_path = level_path + level_data.tile_set
	if (FileAccess.file_exists(ts_path)):
		map_layer.tile_set = ResourceLoader.load(ts_path)
		player_spawn = str_to_var(level_data.player_spawn)
		player_spawn_selector.position = player_spawn
		return true
	return false

## Loads level features via a path. Features must end with .tscn
func load_features(path: String = "res://Scenes/ObjectScenes/Map/"):
	var dir = DirAccess.open(path).get_files()
	var feature_id = 0
	
	for feature in dir:
		if feature.ends_with(".tscn"):
			var button = Button.new()
			button.name = str(feature_id)
			button.text = feature.get_basename()
			button.pressed.connect(_feature_selected.bind(button, feature_id))
			
			var packed_scene: PackedScene = ResourceLoader.load(path + feature)
			features_cache.append(packed_scene)
			
			objects_selector_v_box.add_child(button)
			
			#feature_ids.append(button)
			feature_id = feature_id + 1
			print("Feature: " + feature.get_basename() + " added!")
		else:
			continue

## Adds a feature into the current map.
func add_feature(feature_id: int):
	var button := Button.new()
	var instanced_feature = features_cache[feature_id].instantiate()
	
	button.name = instanced_feature.name
	button.text = instanced_feature.name
	
	
	features.add_child(instanced_feature)
	
	button.pressed.connect(_object_selected.bind(button.name, instanced_feature.get_index()))
	
	tree_v_box.add_child(button)
	
	instanced_feature.position = get_global_mouse_position()
	selected_obj = instanced_feature

func clear_tree():
	for child in tree_v_box.get_children():
		child.queue_free()

# Figure out why names get set to node types in UI.
## Loads all selectable objects and assigns them UI buttons
func reload_tree():
	clear_tree()
	await get_tree().process_frame
	
	for child in features.get_children():
		var button := Button.new()
		button.name = child.name
		button.text = child.name
		button.pressed.connect(_object_selected.bind(button.name, child.get_index()))
		tree_v_box.add_child(button)
		

## Saves all selectable objects with their IDs
func build_tree() -> PackedScene:
	var packed_scene = PackedScene.new()
	var root = Node2D.new()
	var map = map_layer.duplicate(Node.DUPLICATE_SCRIPTS | Node.DUPLICATE_GROUPS | Node.DUPLICATE_SIGNALS)
	var _features = features.duplicate(Node.DUPLICATE_SCRIPTS | Node.DUPLICATE_GROUPS | Node.DUPLICATE_SIGNALS)
	
	root.add_child(_features)
	root.add_child(map)
	
	map.owner = root
	_features.owner = root
	
	for child in _features.get_children():
		child.owner = root
	
	var scene = packed_scene.pack(root)
	if scene == OK:
		return packed_scene
	else: # Find a better way to handle this as this will delete data and progress.
		Globals._recover_to_menu("Error occured while building scene.")
		return

# Add tree feature so already placed / loaded features can be re-selected.

func add_tile():
	var tile : Vector2i = map_layer.local_to_map(selector.global_position)
	if tile_entries.size() > 0:
		var e = tile_entries[selected_entry]
		map_layer.set_cell(tile, e["source_id"], e["atlas"], e["alt"])

func remove_tile():
	var tile : Vector2i = map_layer.local_to_map(selector.global_position)
	if (map_layer.get_cell_source_id(tile) != -1):
		map_layer.erase_cell(tile)

func _feature_selected(button: Button, id: int):
	print("Feature selected: ", button.name + ", ID: " + str(id))
	selected_feature = id

func _object_selected(button_name, instance_id):
	selected_obj = features.get_child(instance_id)
	print("ObjID: " + str(instance_id) + " Obj: " + str(selected_obj))

func refresh_tileset_data():
	tile_entries.clear()
	var ts: TileSet = map_layer.tile_set
	if not ts:
		return
		
	for i in ts.get_source_count():
		var source_id = ts.get_source_id(i)
		var source = ts.get_source(source_id)
		
		if source is TileSetAtlasSource:
			for tile_index in source.get_tiles_count():
				var atlas_coords = source.get_tile_id(tile_index)
				
				for alt_index in source.get_alternative_tiles_count(atlas_coords):
					var alt_id = source.get_alternative_tile_id(atlas_coords, alt_index)
					
					tile_entries.append({
						"source_id": source_id,
						"atlas": atlas_coords,
						"alt": alt_id
					})
					
	selected_entry = 0
	change_selected_tile(m_index.down)

func change_level_name(_name: String = "no-name", is_loading: bool = false):
	level_name = _name
	level_path = GameData.levels_path + _name + "/"
	if (is_loading):
		$LevelDesignerElements/HUD/Control/Ispector/VBoxContainer/LevelName/lvlName.text = _name
	if !(GameData.level_selected == level_name):
		GameData.level_selected = level_name

func directory_builder():
	DirAccess.make_dir_recursive_absolute(GameData.levels_path)
	DirAccess.make_dir_recursive_absolute(level_path)
	DirAccess.make_dir_recursive_absolute(level_path + "data/")

func reload_editor():
	queue_free()
	get_tree().change_scene_to_file("res://Scenes/Levels/LevelDesigner/LevelDesigner.tscn")

func clear_map():
	map_layer.clear()
	set_player_spawn()

func _on_UI_focus_changed(state: bool = true):
	skip_input_check = state
