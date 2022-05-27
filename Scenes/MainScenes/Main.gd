extends Node

onready var bg_music = $"Background Music"
const monster_music = preload("res://Assets/Audio/fog.ogg")

const player_scene = preload("res://Scenes/ObjectScenes/Player.tscn")
const monster_scene = preload("res://Scenes/ObjectScenes/Monster.tscn")

onready var player = player_scene.instance()
onready var monster = monster_scene.instance()

func _ready():
	Globals.connect("monster_spawn", self, "create_monster")
	play_bg_music()
	create_player()

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
	if !Globals.is_counting && Input.is_action_just_pressed("ui_accept"):
		Globals.start_monster_counter()
	elif Globals.is_counting && Input.is_action_just_pressed("ui_accept"):
		Globals.monster_counter = 0.0

func create_player():
	add_child(player)
	player.position = Vector2(get_viewport().size.x / 2, get_viewport().size.y / 2)

func create_monster():
	if !monster.is_inside_tree():
		add_child(monster)
		monster.position = Vector2(get_viewport().size.x / 2.5, 30)
		bg_music.stream = monster_music
		play_bg_music()

func play_bg_music():
	bg_music.play()
