extends AudioStreamPlayer

onready var heartbeat_normal = preload("res://Assets/Audio/SFX/Heart Beat/heartbeat-60bpm.wav")
onready var heartbeat_medium = preload("res://Assets/Audio/SFX/Heart Beat/heartbeat-80bpm.wav")
onready var heartbeat_fast = preload("res://Assets/Audio/SFX/Heart Beat/heartbeat-100bpm.wav")
onready var heartbeat_player_anxiety = preload("res://Assets/Audio/SFX/Heart Beat/heartbeat-120bpm.wav")
onready var heartbeat_player_health_low = preload("res://Assets/Audio/SFX/Heart Beat/heartbeat-140bpm.wav")

enum HeartState {
	normal,
	medium,
	fast,
	anxiety,
	hp_low
}

enum DangerDistance {
	Low = 450,
	Med = 350,
	High = 190
}

#var danger = DangerDistance.Low
var heart_state = HeartState.normal
var change_rate = 2.5
var current_time = -1

# Player
var player_stun = false

# Disable heartbeat effect
var disabled := false

# This script will handle the player's heart beat to bring some anxiety.

func _ready():
	if disabled:
		queue_free()
	
	# Setup events
	Globals.connect("_player_hurt", self, "_on_Player_hurt")
	
	# Setup audio stream
	self.stream = heartbeat_normal
	_set_volume(-10)
	_start_stream()
	pass # Replace with function body.

func _process(delta):
	if Globals.PlayerHealth < 15:
		pass
	elif Globals.PlayerHealth < 35 && !heart_state == HeartState.hp_low:
		change_Heart_state(HeartState.hp_low)
	
	if !player_stun && !heart_state == HeartState.hp_low:
#		print(Globals.distance_from_player)
		if Globals.distance_from_player <= DangerDistance.Low && heart_state == HeartState.normal:
			change_Heart_state(HeartState.medium)
		elif Globals.distance_from_player <= DangerDistance.Med && heart_state == HeartState.medium:
			change_Heart_state(HeartState.fast)
		elif Globals.distance_from_player <= DangerDistance.High && heart_state == HeartState.fast:
			change_Heart_state(HeartState.anxiety)
		elif Globals.distance_from_player > DangerDistance.Low && !heart_state == HeartState.normal:
			change_Heart_state(HeartState.normal)
#		print(str(heart_state))
#		if Globals.distance_from_player >= DangerDistance.High && !heart_state == HeartState.fast:
	
#			change_Heart_state(HeartState.fast)
		
	
	if !heart_state == HeartState.normal && !heart_state == HeartState.hp_low && player_stun:
		current_time += delta
		if current_time > change_rate:
			match heart_state:
#				HeartState.medium:
#					change_Heart_state(HeartState.normal)
				HeartState.fast:
					change_Heart_state(HeartState.medium)
				HeartState.anxiety:
					change_Heart_state(HeartState.fast)

func _start_stream():
	self.play()

func _set_volume(db):
	self.volume_db = db

func _on_Player_hurt():
	current_time = 0
	if !heart_state == HeartState.anxiety:
		change_Heart_state(HeartState.anxiety)
		player_stun = true

#_Heart_state_changed
func change_Heart_state(state):
	heart_state = state
	
	if heart_state == HeartState.normal:
		self.stream = heartbeat_normal
		_set_volume(-10)
	if heart_state == HeartState.medium:
		self.stream = heartbeat_medium
		player_stun = false
		_set_volume(-10)
	if heart_state == HeartState.fast:
		self.stream = heartbeat_fast
		_set_volume(-5)
	if heart_state == HeartState.anxiety:
		self.stream = heartbeat_player_anxiety
		_set_volume(-2)
	if heart_state == HeartState.hp_low:
		self.stream = heartbeat_player_health_low
		_set_volume(0)
	_start_stream()
	current_time = 0
