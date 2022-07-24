extends Control


# Not developed yet.

onready var HBS := $"EnableHBS/HBS"
onready var Fullscreen := $"Fullscreen/Fullscreen"
onready var Monster := $"Monster/Monster"


func _ready():
	HBS.pressed = GameData.HBS
	Fullscreen.pressed = GameData.fullscreen_mode
	Monster.pressed = GameData.MonAI

func _on_CheckBox_toggled(button_pressed):
	print("Not integrated")

func _on_HBS_toggled(button_pressed):
	GameData.HBS = button_pressed

func _on_Fullscreen_toggled(button_pressed):
	GameData.fullscreen_mode = button_pressed
	GameData.update_screen()


func _on_Monster_toggled(button_pressed):
	GameData.MonAI = Monster.pressed
