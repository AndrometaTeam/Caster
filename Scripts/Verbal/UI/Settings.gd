extends Control


# Not developed yet.

onready var HBS := $"EnableHBS/HBS"
onready var Fullscreen := $"Fullscreen/Fullscreen"


func _ready():
	HBS.pressed = GameData.HBS
	Fullscreen.pressed = OS.window_fullscreen

func _on_CheckBox_toggled(button_pressed):
	print("Not integrated")

func _on_HBS_toggled(button_pressed):
	GameData.HBS = button_pressed

func _on_Fullscreen_toggled(button_pressed):
	OS.window_fullscreen = Fullscreen.pressed
