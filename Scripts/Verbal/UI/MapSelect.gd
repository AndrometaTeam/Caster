extends ColorRect

# This script will handle all the level selctor functionality.
# This includes but is not limited to directory reading, item looping,
# item listing, etc.

onready var itemlistbox = $Control/ItemList
onready var default_icon = preload("res://Assets/Textures/Map Graphics/bounds.png")

var currently_selected_index: int = 0

var files : Array = ["Empty Level"]

func _ready():
#	get_tree().change_scene("res://Scenes/Levels/LevelDesigner/LevelDesigner.tscn")
	dir_contents()

# Functional methods.

func dir_contents():
	var dir = Directory.new()
	if dir.open(GameData.levels_path) == OK:
		dir.list_dir_begin(true, true)
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				print("Found directory: " + file_name)
				if (dir.file_exists(GameData.levels_path + file_name + "/icon.png")):
					add_item(file_name, true)
				else:
					add_item(file_name)
			else:
				print("Found file: " + file_name)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")

func add_item(file_name: String, _has_icon: bool = false):
	var selected_icon: Texture = default_icon
	
	if (_has_icon):
		selected_icon = load(GameData.levels_path + file_name + "/icon.png")
		if !(selected_icon.get_size().x == 32 && selected_icon.get_size().y == 32):
			selected_icon = default_icon

	print(selected_icon.get_size())
	
	files.push_back(file_name)
	itemlistbox.add_item(file_name, selected_icon)

func refresh_items():
	files.clear()
	itemlistbox.clear()
	add_item("Empty Level")
	dir_contents()

# UI buttons.

func _on_ItemList_item_selected(index):
#	if (itemlistbox.is_selected(itemlistbox.))
	if (files[index] == "Empty Level"):
		$Control/Load.disabled = true
	else:
		$Control/Load.disabled = false
		currently_selected_index = index

func _on_LoadEditMode_pressed():
	if !(files[currently_selected_index] == "Empty Level"):
		GameData.level_selected = files[currently_selected_index]
	
	get_tree().change_scene("res://Scenes/Levels/LevelDesigner/LevelDesigner.tscn")

func _on_Load_pressed():
	GameData.level_selected = files[currently_selected_index]
	get_tree().change_scene("res://Scenes/MainScenes/Main.tscn")

func _on_RefreshButton_pressed():
	refresh_items()
	pass # Replace with function body.
