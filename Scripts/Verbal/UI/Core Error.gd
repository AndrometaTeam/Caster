extends Control

@onready var label: Label = $Error/Label

func _ready():
	label.text = Globals.crash_message

func _on_Button_pressed():
	queue_free()
	get_tree().change_scene_to_file("res://Scenes/MainScenes/Menu/MainMenu.tscn")
