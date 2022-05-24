extends KinematicBody2D

signal unstunned

const body_id := 1

var speed := 100
var stop_movement := false
var is_stunned := false
var stun_time := 0.0
const TIME_STUNNED := 5.0

func _ready():
	Globals.connect("moster_destroy", self, "destroy_moster")
	Globals.connect("moster_stun", self, "stun_monster")

func _process(delta):
	if is_stunned:
		stun_time += delta

	if stun_time > TIME_STUNNED:
		emit_signal("unstunned")
		stun_time = 0
		is_stunned = false
		stop_movement = false

func _physics_process(delta):
	if !stop_movement:
		var motion = transform.x * speed * delta
		position += motion
		look_at(Globals.player_pos)
#		stop_movement = false

func destroy_moster():
	queue_free()

func stun_monster():
	if !is_stunned:
		is_stunned = true
		stop_movement = true

func _on_Area2D_body_entered(body):
	if body.body_id == 0 && !is_stunned:
		Globals.player_dead()
		stop_movement = true
