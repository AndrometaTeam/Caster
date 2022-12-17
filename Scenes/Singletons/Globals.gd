extends Node

# Player signals (HELP)
signal _player_ready
signal _player_hurt
signal _stamina_changed
signal _player_is_dead
signal _fire
signal _hidden_status

# GUI / UI
signal _no_ammo
signal _no_stam

# Monster signals
signal moster_destroy
signal moster_stun
signal monster_spawn
# Monster AI signals
signal map_update


# Other signals
signal _is_counting

# Menu state variables
var game_started: bool = false

# Global Player pointer variables 
var player_pos := Vector2.ZERO
var player_hidden_status := false

# Global Monster pointer variables
var monster_pos := Vector2.ZERO
var distance_from_player := 0

#Stats
var PlayerHealth
var PlayerStamina
var PlayerAmmo

# Gamemode Variables
#var TimeLeft

var monster_counter := 10.0
var is_counting := false

# Learn how to add view ports and screen size control.

func _process(delta):
	if is_counting:
		monster_counter -= delta
		emit_signal("_is_counting")
	if monster_counter <= 0:
		is_counting = false
		monster_counter = 10.0
		emit_signal("monster_spawn")


func start_monster_counter():
	is_counting = true

func stun_monster(TIME_STUNNED = 5.0):
	emit_signal("moster_stun", TIME_STUNNED)

func destroy_monster():
	emit_signal("moster_destroy")

func player_hide(STATUS = true):
	emit_signal("_hidden_status", STATUS)

func player_dead():
	emit_signal("_player_is_dead")

func player_hurt():
	emit_signal("_player_hurt")

func stamina_changed():
	emit_signal("_stamina_changed")

func fire():
	emit_signal("_fire")

func _recover_to_menu():
	get_tree().current_scene.queue_free()
	get_tree().change_scene("res://Scenes/ObjectScenes/Messages/Core Error.tscn")

func _return_to_menu():
	get_tree().current_scene.queue_free()
	get_tree().change_scene("res://Scenes/MainScenes/Menu/MainMenu.tscn")

func _validate_maphook(mapnode: Node):
	if mapnode.has_method("_validate_level"):
		var data : Array = mapnode._validate_level()
		if !(data[0] == GameData.build_version):
			_recover_to_menu()
		if (data[1] == "0"):
			mapnode.set_script(null)
	else:
		print("No core script to validate.")
