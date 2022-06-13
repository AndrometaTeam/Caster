extends KinematicBody2D

const ACCELERATION = 595
const FRICTION = 595
const ABSOLUTE_MAX_SPEED = 240 # Unchangable speed cap
const ABSOLUTE_WALKING_SPEED = 145
const DEFAULT_ANGLE = -1.5708
const STAMINA_DRAIN_RATE = 20
const STAMINA_RECHARGE_RATE = 13
var SPEED = 145 # Allow for faster movements

var weight = 0.5
var target_pos = Vector2.ZERO
var velocity = Vector2.ZERO

# Other interesting fun things to test and play with.
var MAX_HEALTH = 200
var MAX_STAMINA := 100.0
var MAX_AMMO = 120

var health = 100
var stamina = 100
var ammo = 10
var melee_mode := false
var is_player_hidden := false #Add hiding feature to get away from the monster.

# Physically physical.
onready var Collider2D = $PhysicalBody

# Graphics (Textures / Sprite)
const player = preload("res://Assets/Textures/Entity Graphics/Player/player.png")
const player_hidden = preload("res://Assets/Textures/Entity Graphics/Player/player_hidden.png")
onready var player_graphic = $PlayerGraphic

# Bullet
const bullet_scene = preload("res://Scenes/ObjectScenes/Bullet.tscn")
var bullet_speed = 20

# Controls stuff
var is_mouse_looking = false

func _ready():
	# Set pointers / signals from global
	Globals.connect("_player_hurt", self, "_on_Player_hurt")
	Globals.connect("_hidden_status", self, "_on_Player_hidden_changed")
	Globals.PlayerHealth = health
	Globals.PlayerStamina = stamina
	Globals.PlayerAmmo = ammo
	
	# Setup graphics
	player_graphic.texture = player
	
	
	Globals.emit_signal("_player_ready")

func _physics_process(delta): # Handles most of the player mechanics and extras
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	if input_vector != Vector2.ZERO:
		velocity = velocity.move_toward(input_vector * SPEED, ACCELERATION * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	# For moving the player
	velocity = move_and_slide(velocity)
	target_pos = get_global_mouse_position()
	if !is_player_hidden: Globals.player_pos = global_position
	
	# This handles the input / check / math behind the player stamina
	if Input.is_action_pressed("sprint") && stamina >= 0 && !velocity == Vector2.ZERO:
		_player_speed(ABSOLUTE_MAX_SPEED)
		_player_stamina_drain(delta)
	else:
		_player_speed(ABSOLUTE_WALKING_SPEED)

	Globals.distance_from_player = round(abs(position.distance_to(Globals.monster_pos)))

## Experimenting (Best I can do until I come across some better math)
	var SignleVarSpeed := round(velocity.dot(velocity) / float(10^100))
	
	if stamina < MAX_STAMINA: # This check allows for dynamic-ish stamina recharge.
		if velocity == Vector2.ZERO && health > 62:
			_player_stamina_recharge(delta, STAMINA_RECHARGE_RATE)
		elif velocity == Vector2.ZERO && health > 42:
			_player_stamina_recharge(delta, STAMINA_RECHARGE_RATE / 1.5)			
		elif SignleVarSpeed <= 524 && !Input.is_action_pressed("sprint"): # Currently causing a UI bug.
			_player_stamina_recharge(delta, STAMINA_RECHARGE_RATE / 2.5)
			
	# Mouse input for player rotation
	if Input.is_action_pressed("right_nouse"):
		_mouse_look_function(true)
	elif Input.is_action_pressed("reset_mouse"):
		_mouse_look_function(false)
	else:
		is_mouse_looking = false
	
	# Combat input (Add melee as a changable mode eventually.
	if Input.is_action_pressed("left_mouse") && melee_mode: 
		melee()
	if Input.is_action_just_pressed("left_mouse") && is_mouse_looking == true && !melee_mode:
		fire()


func _player_speed(speed):
	SPEED = speed

func _player_stamina_recharge(delta, STAMINA_RECHARGE_RATE):
	stamina += STAMINA_RECHARGE_RATE * delta
	Globals.PlayerStamina = abs(round(stamina))
	Globals.stamina_changed()

func _player_stamina_drain(delta):
	stamina -= STAMINA_DRAIN_RATE * delta
	Globals.PlayerStamina = abs(round(stamina))
	if stamina <= 0.0:
		Globals.emit_signal("_no_stam")
	else:
		Globals.stamina_changed()	

func _mouse_look_function(is_looking): 
	if is_looking:
		rotation = lerp_angle(self.rotation, (target_pos - global_position).normalized().angle(), weight)
		is_mouse_looking = true
	else:
		rotation = lerp_angle(self.rotation, DEFAULT_ANGLE, weight)
		is_mouse_looking = false

func _on_Player_hurt():
	health -= round(rand_range(5, 14))
	if health <= 0:
		health = 0
		Globals.player_dead()
		queue_free()
	Globals.PlayerHealth = health

func melee(): # Melee to stun the monster (Needs work)
	Globals.stun_monster(1.5)

func fire(): #	Shooting to stun the monster.
	if ammo > 0:
		var bullet = bullet_scene.instance()
		
		get_parent().add_child(bullet)
		bullet.position = $BulletRoot/Position2D.global_position
		bullet.rotation = rotation - bullet.rotation
		ammo -= 1
		Globals.PlayerAmmo = ammo
		Globals.fire()
	else:
		Globals.emit_signal("_no_ammo")

func _on_Player_hidden_changed(status):
	is_player_hidden = status
	Globals.player_hidden_status = status
	
	if status:
		player_graphic.texture = player_hidden
	else:
		player_graphic.texture = player	

# This is for melee
func _on_AttackBox_body_entered(body):
	if body.collision_layer == 2:
		melee_mode = true

func _on_AttackBox_body_exited(body):
	if body.collision_layer == 2:
		melee_mode = false
