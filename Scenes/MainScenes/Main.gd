extends Node

onready var bg_music = $"Background Music"

func _ready():
	play_bg_music()

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()


func play_bg_music():
	bg_music.play()
