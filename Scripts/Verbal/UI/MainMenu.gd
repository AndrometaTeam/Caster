extends CanvasLayer

func _ready():
	if get_tree().paused: get_tree().paused = false
	if Globals.game_started:
		close_info()

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
	if Input.is_action_just_pressed("ui_select"):
		close_info()
		Globals.game_started = true


# Menu functions

func close_info():
		$Control/About.visible = false
		$Control/Menu.visible = true

# Menu signal functions

func _on_Button_pressed():
	get_tree().change_scene("res://Scenes/MainScenes/Main.tscn")


func _on_Options_pressed():
	$Control/Options.visible = true
	$Control/Menu.visible = false

func _on_Exit_pressed():
	get_tree().quit()

# Options functions

func _on_BackBNT_pressed():
	$Control/Options.visible = false
	$Control/Menu.visible = true
