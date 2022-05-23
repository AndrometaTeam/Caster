extends Node

signal player_is_dead
signal moster_destroy
signal moster_stun

var player_pos := Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func stun_monster():
	emit_signal("moster_stun")

func destroy_monster():
	emit_signal("moster_destroy")

func player_dead():
	emit_signal("player_is_dead")
