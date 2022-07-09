extends Node2D

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
			"player_spawn": player_spawn,
			"map_data": var2str(map)
		}
		save_level(save_dict)
	
	if (Input.is_action_just_pressed("move_down")):
		player_spawn = get_global_mouse_position()
	
	if (Input.is_action_just_released("mouse_wheel_up")): 
		change_selected_tile(m_index.up)

	elif (Input.is_action_just_released("mouse_wheel_down")):
		change_selected_tile(m_index.down)
	
	if (Input.is_action_just_pressed("right_mouse")):
		var tile : Vector2 = map.world_to_map(selector.mouse_pos * snap_size.x)
		if (map.get_cellv(tile) != -1):
			map.set_cellv(tile, -1)
		
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

func save_level(data: Dictionary):
	var f := File.new()
	f.open("res://save.json", File.WRITE)
	prints("Saving to ", f.get_path_absolute())
	f.store_string(JSON.print(data))
	f.close()

enum m_index {
	up,
	down
}
