extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	if get_tree().paused: get_tree().paused = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

# Menu functions

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
