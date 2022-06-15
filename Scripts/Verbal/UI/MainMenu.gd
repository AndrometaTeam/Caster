extends CanvasLayer

func _ready():
	if get_tree().paused: get_tree().paused = false
	if Globals.game_started: toggle_info()

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
	if Input.is_action_just_pressed("space"):
		toggle_info()
		Globals.game_started = true


# Menu functions

func toggle_info():
		$Control/About.visible = !$Control/About.visible
		$Control/Menu.visible = !$Control/Menu.visible

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
