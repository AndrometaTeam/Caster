extends Node

# Node variables
@onready var bg_music = $"Background Music"
@onready var LevelNode = $LevelNode

# File variables
const monster_music = preload("res://Assets/Audio/Music/fog.ogg")

const player_scene = preload("res://Scenes/ObjectScenes/Player/Player.tscn")
const monster_scene = preload("res://Scenes/ObjectScenes/Monster.tscn")
const levels = [preload("res://Scenes/Levels/devel-level0.tscn"), preload("res://Scenes/Levels/level-loader.tscn")]

@onready var player = player_scene.instantiate()
#@onready var monster = monster_scene.instantiate()

var selected_level_name = GameData.level_selected
var current_scene = levels[0].instantiate()

func _ready():
	Globals.connect("monster_spawn", Callable(self, "create_monster"))
	
	# Check the current selected level for the devel-level scene.
	print("Level Name: " + selected_level_name)
	if !(selected_level_name == "no-level"):
		current_scene = levels[1].instantiate()
		current_scene.player = player
	else:
		current_scene = levels[0].instantiate()
		current_scene.player = player
		# Instance the level and set variables
	LevelNode.add_child(current_scene)
	
#	print_tree_pretty()
	
	play_bg_music()
	
	if (current_scene):
		create_player()
	else:
		queue_free()

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		toggle_pause_menu()

#	if !monster.is_inside_tree() && GameData.MonAI && !Globals.is_counting && Input.is_action_just_pressed("space"):
#		Globals.start_monster_counter()
#	elif !monster.is_inside_tree() && GameData.MonAI && Input.is_action_just_pressed("space"):
#		Globals.monster_counter = 0.0

func create_player():
	add_child(player)
#	player.position = current_scene.get_node("PlayerSpawn").global_position

#func create_monster():
#	if !monster.is_inside_tree() && !GameData.disable_monster:
#		add_child(monster)
#		monster.position = current_scene.get_node("MonsterSpawn").global_position
#		bg_music.stream = monster_music
#		play_bg_music()

func load_level() -> Dictionary:
	var f = FileAccess.open("res://save.json", FileAccess.READ)
#	f.open_encrypted_with_pass("res://save.json", File.READ, Encryption.get_key())
	var test_json_conv = JSON.new()
	test_json_conv.parse(f.get_as_text())
	var result = test_json_conv.get_data()
	f.close()
	
	if result.error:
		printerr("Failed to parse map data...")

	return {}

func play_bg_music():
	bg_music.play()

func toggle_pause_menu():
	var Menu = $EscapeMenu
	Menu.toggle_menu()
