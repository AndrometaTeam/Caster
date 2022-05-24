extends Node

signal player_is_dead
signal moster_destroy
signal moster_stun
signal monster_spawn

var player_pos := Vector2.ZERO

var monster_counter := 15.0
var is_counting := false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _process(delta):
	if is_counting:
		monster_counter -= delta
	if monster_counter <= 0:
		is_counting = false
		monster_counter = 15.0
		emit_signal("monster_spawn")


func start_monster_counter():
	is_counting = true

func stun_monster():
	emit_signal("moster_stun")

func destroy_monster():
	emit_signal("moster_destroy")

func player_dead():
	emit_signal("player_is_dead")
