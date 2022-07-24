extends Node

# Data
var skilldata

# Level Persist settings
var levels = [preload("res://Scenes/Levels/devel-level0.tscn")]
var level_selected: String = "no-level"
var levels_path: String = "res://Saves/" # Change to "res://Maps/"

# Note: if the game doesn't work at runtime, try OS.get_executable_path() instead of
# "res://"

# Globalized Settings
var HBS = false
var MonAI = false

# Cheats
var disable_monster = false

# Files
var game_data = File.new()

func _ready(): # Early start messages.
	print("===== Made by KiloDev =====")
	print("This project is early and in development.")
	print("README: Visit the itch page for official builds!")
	print("Visit the github for official project developments.")
	print("Itch: https://andrometa.itch.io/caster")
	print("GitHub: https://github.com/KiloDev/Caster")
	print("===== Andrometa Team  =====")
	print("Programmer / Maintainer: KiloDev")
	print("Lead Artist: FroggyOverlord (Currently Unavaliable)")
	
	if (!game_data.file_exists("res://Data/settings.res")):
		settings_save()
	else:
		settings_loader()
#	var skilldata_file = File.new()
#	skilldata_file.open("res://Data/SkillData.json", File.READ)
#	var skilldata_json = JSON.parse(skilldata_file.get_as_text())
#	skilldata_file.close()
#	skilldata = skilldata_json.result

func settings_save():
	game_data.open("res://Data/settings.tres", File.WRITE)
	game_data.store_string(var2str(generate_settings_dictionary()))
	game_data.close()

func settings_loader():
	game_data.open("res://Data/settings.tres", File.READ)
	var dict : Dictionary = str2var(game_data.get_as_text())
	HBS = dict.heartbeat_sys
	MonAI = dict.monster_ai
	disable_monster = dict.disable_monster
	game_data.close()
	print("Settings loaded...")

func generate_settings_dictionary() -> Dictionary:
	var dict : Dictionary = {
		"heartbeat_sys": HBS,
		"monster_ai": MonAI,
		"disable_monster": disable_monster
	}
	
	return dict
