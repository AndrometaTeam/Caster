extends SubViewport


var MainScene = preload("res://Scenes/MainScenes/Main.tscn")

var currentScene

func _ready():
	currentScene = MainScene.instantiate()
	add_scene_instance(currentScene)

func add_scene_instance(instance):
	add_child(instance)
