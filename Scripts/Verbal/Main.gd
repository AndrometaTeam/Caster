extends Node

# Node variables
onready var bg_music = $"Background Music"
onready var map = $"MapNode"

# File variables
const monster_music = preload("res://Assets/Audio/Music/fog.ogg")

const player_scene = preload("res://Scenes/ObjectScenes/Player/Player.tscn")
const monster_scene = preload("res://Scenes/ObjectScenes/Monster.tscn")
const levels = [preload("res://Scenes/Levels/devel-level0.tscn")]

onready var player = player_scene.instance()
onready var monster = monster_scene.instance()
var current_level = null


func _ready():
	Globals.connect("monster_spawn", self, "create_monster")
	
	# Instance the level
	current_level = levels[0].instance()
	current_level.player = player
	map.add_child(current_level)
	
	play_bg_music()
	if current_level:
		create_player()
	else:
		queue_free()

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		toggle_pause_menu()

	if !monster.is_inside_tree() && GameData.MonAI && !Globals.is_counting && Input.is_action_just_pressed("space"):
		Globals.start_monster_counter()
	elif !monster.is_inside_tree() && GameData.MonAI && Input.is_action_just_pressed("space"):
		Globals.monster_counter = 0.0

func create_player():
	add_child(player)
	player.position = current_level.get_node("PlayerSpawn").global_position

func create_monster():
	if !monster.is_inside_tree() && !GameData.disable_monster:
		add_child(monster)
		monster.position = current_level.get_node("MonsterSpawn").global_position
		bg_music.stream = monster_music
		play_bg_music()

func play_bg_music():
	bg_music.play()

func toggle_pause_menu():
	var MenuRoot = get_node("EscapeMenu").get_node("MenuRoot")
	MenuRoot.visible = !MenuRoot.visible
	get_tree().paused = MenuRoot.visible
