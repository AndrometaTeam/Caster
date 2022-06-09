extends KinematicBody2D

signal unstunned

# Collision trackers
var is_player_in_body := false

# Monster variables
var speed := 175
var disable_movement := false
var is_stunned := false
var is_hurting_player := false

var hurt_delay := 0.0
var stun_time := 0.0
var TIME_STUNNED := 5.0

func _ready():
	Globals.connect("moster_destroy", self, "destroy_moster")
	Globals.connect("moster_stun", self, "stun_monster")
	Globals.connect("_player_is_dead", self, "_on_Player_died")

func _process(delta):
	if is_stunned:
		stun_time += delta
	
	if is_hurting_player:
		hurt_delay += delta
	
	if hurt_delay > .550:
		hurt_delay = 0
		Globals.player_hurt()

	if stun_time > TIME_STUNNED:
		if is_player_in_body: is_hurting_player = true
		emit_signal("unstunned")
		stun_time = 0
		TIME_STUNNED = 5.0
		is_stunned = false
		disable_movement = false

func _physics_process(delta):
	if !disable_movement && !Globals.player_hidden_status:
#		var motion = transform.x * speed * delta
#		position += motion

		# Add an AI that allows for hunting, patroling, ect.

		# Trig is hard.
		# Experiment with different movement methods.
		move_and_slide(Vector2(cos(rotation), sin(rotation)) * speed) # Some work needs to be done.
		rotation = lerp_angle(self.rotation, (Globals.player_pos - global_position).normalized().angle(), 0.1)
		Globals.monster_pos = position
#		look_at(Globals.player_pos)
#		disable_movement = false

func destroy_moster():
	queue_free()

func stun_monster(_TIME_STUNNED):
	if !is_stunned:
		TIME_STUNNED = _TIME_STUNNED
		is_stunned = true
		disable_movement = true

func _on_Player_died():
	disable_movement = true

func _on_Area2D_body_entered(body):
	if body.collision_layer == 1:
		is_player_in_body = true # Keeps track of the players collision status with the Area2D
		if !is_stunned: # Checks wether the monster is stunned.
			Globals.player_hurt()
			is_hurting_player = true

func _on_Area2D_body_exited(body):
	if body.collision_layer == 1: 
		is_player_in_body = false  # Keeps track of the players collision status with the Area2D
		is_hurting_player = false
