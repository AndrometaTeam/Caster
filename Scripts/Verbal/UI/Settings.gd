extends Control

# Not developed yet.

@onready var HBS := $"EnableHBS/HBS"
@onready var Fullscreen := $"Fullscreen/Fullscreen"
@onready var Modding: CheckBox = $"Modding/Modding"


func _ready():
	HBS.button_pressed = GameData.HBS
	Fullscreen.button_pressed = GameData.fullscreen_mode
	Modding.button_pressed = GameData.cmdk_enabled

func _on_CheckBox_toggled(button_pressed):
	print("Not integrated")

func _on_HBS_toggled(button_pressed):
	GameData.HBS = button_pressed

func _on_Fullscreen_toggled(button_pressed):
	GameData.fullscreen_mode = button_pressed
	GameData.update_screen()

func _on_monster_toggled(toggled_on: bool) -> void:
	GameData.MonAI = toggled_on

func _on_modding_toggled(toggled_on: bool) -> void:
	GameData.cmdk_enabled = toggled_on
