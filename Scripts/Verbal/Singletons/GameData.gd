extends Node


# Data
var skilldata
var build_version : int = 0253
var build_version_string : String = "0.2.5.3"
var engine_version = Engine.get_version_info()["string"]

# Level Persist settings
var levels = [preload("res://Scenes/Levels/devel-level0.tscn")]
var level_selected: String = "no-level"

var levels_path: String = "res://Saves/" # Change to "res://Maps/"

# Note: if the game doesn't work at runtime, try OS.get_executable_path() instead of
# "res://"

# Globalized Settings
var HBS = false
var MonAI = false
var fullscreen_mode = false

# Cheats
var disable_monster = false

# Files / Directories
var home_dir = "res://"
var settings_file = home_dir + "/data/settings.json"

var data = DirAccess.open(home_dir)


func _ready(): # Early start messages.
	print(settings_file)
	#print(data.)
	
	print("===== Made by KiloDev =====")
	print("This project is early and in development.")
	print("README: Visit the itch page for official builds!")
	print("Visit the github for official project developments.")
	print("Itch: https://andrometa.itch.io/caster")
	print("GitHub: https://github.com/AndrometaTeam/Caster")
	print("===== Andrometa Team  =====")
	print("Programmer / Maintainer: KiloDev")
	print("Lead Artist: FroggyOverlord (Currently Unavaliable)")
	print("===== Godot =====")
	print("Version: " + engine_version)
	print("==== Application ====")
	print("Version: " + build_version_string + "_" + str(build_version))
	
	if !(OS.is_debug_build()):
		levels_path = OS.get_executable_path().get_base_dir() + "/saves/" # Change to "res://Maps/"
		
	
	if (!FileAccess.file_exists(settings_file)):
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
	
	var game_data = FileAccess.open(settings_file, FileAccess.WRITE)
	game_data.store_string(var_to_str(generate_settings_dictionary()))
	game_data = null

func settings_loader():
	var game_data = FileAccess.open(home_dir + "/data/settings.json", FileAccess.READ)
	var dict : Dictionary = str_to_var(game_data.get_as_text())
	HBS = dict.heartbeat_sys
	MonAI = dict.monster_ai
	disable_monster = dict.disable_monster
	fullscreen_mode = dict.fullscreen
	game_data = null
	
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
	get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN if (fullscreen_mode) else Window.MODE_WINDOWED
