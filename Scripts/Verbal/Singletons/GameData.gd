extends Node


# Data
var skilldata
var build_version : int = 0267
var build_version_string : String = "0.2.6.7"

# Level Persist settings
var levels = [preload("res://Scenes/Levels/devel-level0.tscn")]
var level_selected: String = "no-level"

var levels_path: String = "res://Maps/"  # Change to "res://Maps/"
#OS.get_executable_path().get_base_dir() + "/maps/"

# Note: if the game doesn't work at runtime, try OS.get_executable_path().get_base_dir() + "/maps/" instead of
# "res://Maps/" and use /Maps/ for runtime.

# Globalized Settings
var HBS: bool = false
var fullscreen_mode: bool = false
var cmdk_enabled: bool = false

# Cheats
var disable_monster: bool = false

# Files / Directories
var game_data: FileAccess
var data: DirAccess

var home_dir = OS.get_executable_path().get_base_dir()
var settings_file = home_dir + "/data/settings.json"
var mods_dir = "res://Mods/"

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
	print("Levels path: " + levels_path)

	if !(OS.is_debug_build()):
		levels_path = home_dir + "/maps/"
		mods_dir = home_dir + "/mods/"
	
	if !Cmdk:
		cmdk_enabled = false
	
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
	print(home_dir + "/data")
	if !(DirAccess.open(home_dir).dir_exists(home_dir + "/data")):
		DirAccess.open(home_dir).make_dir(home_dir + "/data")
	
	game_data = FileAccess.open(settings_file, FileAccess.WRITE)
	game_data.store_string(var_to_str(generate_settings_dictionary()))
	game_data.close()

func settings_loader():
	game_data = FileAccess.open(home_dir + "/data/settings.json", FileAccess.READ)
	var dict : Dictionary = str_to_var(game_data.get_as_text())
	
	if dict.has("heartbeat_sys"): HBS = dict.heartbeat_sys
	if dict.has("fullscreen"): fullscreen_mode = dict.fullscreen 
	if dict.has("modding"): cmdk_enabled = dict.modding
	game_data.close()
	
	update_screen()
	
	print("Settings loaded...")

func generate_settings_dictionary() -> Dictionary:
	var dict : Dictionary = {
		"heartbeat_sys": HBS,
		"disable_monster": disable_monster,
		"fullscreen": fullscreen_mode,
		"modding": cmdk_enabled
	}
	
	return dict

func update_screen():
	get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN if (fullscreen_mode) else Window.MODE_WINDOWED
