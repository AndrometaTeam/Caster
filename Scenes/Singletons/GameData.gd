extends Node

# Data
var skilldata

# Level Persist settings
var levels = [preload("res://Scenes/Levels/devel-level0.tscn")]
var level_selected: String = "no-level"
var levels_path: String = OS.get_executable_path().get_base_dir() + "/Saves/" # Change to "res://Maps/"
#var levels_path: String = "res://Saves/" # Change to "res://Maps/"

# Note: if the game doesn't work at runtime, try OS.get_executable_path() instead of
# "res://"

# Globalized Settings
var HBS = false
var MonAI = false
var fullscreen_mode = false

# Cheats
var disable_monster = false

# Files / Directories
var game_data = File.new()
var data = Directory.new()

var home_dir = OS.get_executable_path().get_base_dir()
var settings_file = home_dir + "/data/settings.json"


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
	
	if (!game_data.file_exists(settings_file)):
		settings_save()
	else:
		settings_loader()
#	var skilldata_file = File.new()
#	skilldata_file.open("res://Data/SkillData.json", File.READ)
#	var skilldata_json = JSON.parse(skilldata_file.get_as_text())
#	skilldata_file.close()
#	skilldata = skilldata_json.result

func settings_save():
	if !(data.dir_exists(home_dir + "/data")):
		data.make_dir(home_dir + "/data")
	
	game_data.open(settings_file, File.WRITE)
	game_data.store_string(var2str(generate_settings_dictionary()))
	game_data.close()

func settings_loader():
	game_data.open(home_dir + "/data/settings.json", File.READ)
	var dict : Dictionary = str2var(game_data.get_as_text())
	HBS = dict.heartbeat_sys
	MonAI = dict.monster_ai
	disable_monster = dict.disable_monster
	fullscreen_mode = dict.fullscreen
	game_data.close()
	
	update_screen()
	
	print("Settings loaded...")

func generate_settings_dictionary() -> Dictionary:
	var dict : Dictionary = {
		"heartbeat_sys": HBS,
		"monster_ai": MonAI,
		"disable_monster": disable_monster,
		"fullscreen": fullscreen_mode
	}
	
	return dict

func update_screen():
	OS.window_fullscreen = fullscreen_mode
