extends Node

signal alive
signal dead
signal error

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	# Load your mod scripts
	
	# Let the core know that everything is working.
	emit_signal("dead")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
