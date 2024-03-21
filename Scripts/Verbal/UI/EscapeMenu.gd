extends CanvasLayer

@onready var MenuRoot = $MenuRoot
@onready var PauseMenu = $MenuRoot/Pause

func _ready():
	MenuRoot.visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS

func toggle_menu():
	MenuRoot.visible = !MenuRoot.visible
	get_tree().paused = MenuRoot.visible

func _on_Resume_pressed():
	MenuRoot.visible = false
	get_tree().paused = false


func _on_MainMenu_pressed():
	get_tree().change_scene_to_file("res://Scenes/MainScenes/Menu/MainMenu.tscn")
