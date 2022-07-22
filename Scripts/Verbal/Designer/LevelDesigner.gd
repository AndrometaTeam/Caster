extends Node2D

onready var LevelDesigner : Node2D = $LevelDesignerElements
onready var HUD : CanvasLayer = $LevelDesignerElements/HUD

onready var map : TileMap = $TileMap
onready var selector : Sprite = $selector
onready var snap_size : Vector2 = selector.snap_size
onready var tile_ids : Array = map.tile_set.get_tiles_ids()

var tile_max_id : int = 0
var selected_id : int = 0

var player_spawn : Vector2 = Vector2(10, 10)

var save_dict : Dictionary = {}

func _ready():
	tile_max_id = tile_ids.size() - 1
	change_selected_tile(m_index.down)

func _physics_process(delta):
	if (Input.is_action_just_pressed("ui_cancel")):
		get_tree().quit()
	
	if (Input.is_action_just_pressed("interact")):
		save_dict = {
			"player_spawn": var2str(player_spawn),
			"tile_set": "res://Assets/LevelDesigner.tres"
#			"map_data": var2str(map)
		}
		save_level(save_dict)
	
	if (Input.is_action_just_pressed("builder_load_level")):
		var level = load_level()
		if (level.empty()):
			print("Loading was skipped...")
		else:
			player_spawn = str2var(level.player_spawn)
			var tile_set = str2var(level.tile_set)
			print(tile_set)
			var tileset :TileSet = ResourceLoader.load(level.tile_set)
			map.tile_set = tileset
#			map = str2var(level.map_data)

	if (Input.is_action_just_pressed("move_down")):
		player_spawn = get_global_mouse_position()

	if (Input.is_action_just_released("mouse_wheel_up")): 
		change_selected_tile(m_index.up)

	elif (Input.is_action_just_released("mouse_wheel_down")):
		change_selected_tile(m_index.down)

	if (Input.is_action_pressed("right_mouse")):
		var tile : Vector2 = map.world_to_map(selector.mouse_pos * snap_size.x)
		if (map.get_cellv(tile) != -1):
			map.set_cellv(tile, -1)

# This allows you to place the currently selected tile at your mouse position
# based on your snap size.
	if (Input.is_action_pressed("left_mouse")):
		var tile : Vector2 = map.world_to_map(selector.mouse_pos * snap_size.x)
		map.set_cellv(tile, selected_id)


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
#	$LevelDesignerElements/HUD/Control.visible = false
	
	var packed_scene = PackedScene.new()
	packed_scene.pack(map)
	ResourceSaver.save("res://Saves/save.tscn", packed_scene)
	
	reload_editor()

func load_level_scene():
	var packed_scene = load("res://Saves/save.tscn")
	var instanced_scene = packed_scene.instance()
	
	var scene_handler = $LevelDesignerElements/SceneInstances
	
	scene_handler.add_child(instanced_scene)
	
	var loaded_tilemap : TileMap = instanced_scene
	var all_tiles_zero_cells = loaded_tilemap.get_used_cells_by_id(0)
	var all_cells_zero_tiles = loaded_tilemap.get_used_cells()
	
	
	for i in all_cells_zero_tiles:
		map.set_cellv(i, loaded_tilemap.get_cellv(i))

	instanced_scene.free()
	print("Root (Post-load)")
	print_tree_pretty()
#	$TileMap = scene_handler.get_node("Level2").get_node("TileMap")
#	get_tree().current_scene.print_tree()

func reload_editor():
	queue_free()
	get_tree().change_scene("res://Scenes/Levels/LevelDesigner/LevelDesigner.tscn")
	print("Root (Post-Reload)")
	print_tree_pretty()

func save_level(data: Dictionary):
	var f := File.new()
	f.open("res://Saves/save.json", File.WRITE)
#	f.open_encrypted_with_pass("res://Saves/save.json", File.WRITE, Encryption.get_key())
	print("Saving to ", f.get_path_absolute())
	f.store_string(JSON.print(data))
	f.close()
	save_level_scene()

# This load_level function makes calls to save the variable and scene data.
# It's extremely important to load level data and is very promising.\

func load_level() -> Dictionary:
	var f := File.new()
#	f.open_encrypted_with_pass("res://Saves/save.json", File.READ, Encryption.get_key())
	f.open("res://Saves/save.json", File.READ)
	var result := JSON.parse(f.get_as_text())
	f.close()
	
	if (result.error != OK):
		print("Failed to parse map data...")
	elif (typeof(result.result) == TYPE_DICTIONARY):
		print("Map successfully parsed.")
		load_level_scene()
		return result.result as Dictionary
	else:
		push_error("Parsing failed...")
	return {}
