extends Node

# Node variables
onready var bg_music = $"Background Music"
onready var map = $"MapNode"

# File variables
const monster_music = preload("res://Assets/Audio/Music/fog.ogg")

const player_scene = preload("res://Scenes/ObjectScenes/Player.tscn")
const monster_scene = preload("res://Scenes/ObjectScenes/Monster.tscn")
const levels = [preload("res://Scenes/Levels/devel-level0.tscn")]

onready var player = player_scene.instance()
onready var monster = monster_scene.instance()
var current_level = null


func _ready():
	Globals.connect("monster_spawn", self, "create_monster")
	
	# Instance the level
	current_level = levels[0].instance()
	map.add_child(current_level)
	
	play_bg_music()
	create_player()

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().change_scene("res://Scenes/MainScenes/Menu/MainMenu.tscn")
	if !Globals.is_counting && Input.is_action_just_pressed("ui_accept"):
		Globals.start_monster_counter()
	elif Globals.is_counting && Input.is_action_just_pressed("ui_accept"):
		Globals.monster_counter = 0.0

func create_player():
	add_child(player)
	player.position = Globals.player_pos

func create_monster():
	if !monster.is_inside_tree() && !GameData.disable_monster:
		add_child(monster)
		monster.position = Vector2(get_viewport().size.x / 2.5, 30)
		bg_music.stream = monster_music
		play_bg_music()

func play_bg_music():
	bg_music.play()
