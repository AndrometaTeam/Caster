extends KinematicBody2D

const body_id = 0

const ACCELERATION = 595
const FRICTION = 595
const ABSOLUTE_MAX_SPEED = 240 # Unchangable speed cap
const ABSOLUTE_WALKING_SPEED = 145
const DEFAULT_ANGLE = -1.5708
const STAMINA_DRAIN_RATE = 20
const STAMINA_RECHARGE_RATE = 5
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
const player = preload("res://Assets/Textures/player.png")
const player_hidden = preload("res://Assets/Textures/player_hidden.png")
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
	if !is_player_hidden: Globals.player_pos = position
	
	# This handles the input / check / math behind the player stamina
	if Input.is_action_pressed("sprint") && stamina >= 0 && !velocity == Vector2.ZERO:
		_player_speed(ABSOLUTE_MAX_SPEED)
		_player_stamina_drain(delta)
	else:
		_player_speed(ABSOLUTE_WALKING_SPEED)
	
	if stamina < MAX_STAMINA && velocity == Vector2.ZERO:
		_player_stamina_recharge(delta)
	
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
	
	# $BulletRoot.look_at(target_pos) # Set to player position. No longer needed?
# Set rotation of bullet root to the rotation of the player.
#	look_at(target_pos) // Alternative for mouse look features.

func _player_speed(speed):
	SPEED = speed

func _player_stamina_recharge(delta):
	stamina += STAMINA_DRAIN_RATE * delta
	Globals.PlayerStamina = round(stamina)
	Globals.stamina_hurt()

func _player_stamina_drain(delta):
	stamina -= STAMINA_DRAIN_RATE * delta
	Globals.PlayerStamina = round(stamina)
	Globals.stamina_hurt()
	if stamina <= 0.0:
		Globals.emit_signal("_no_stam")

# Maybe lerp the monsters rotation as well for fairness melee (CONSIDER)
func _mouse_look_function(is_looking): 
	if is_looking:
		rotation = lerp_angle(self.rotation, (target_pos - global_position).normalized().angle(), weight)
		is_mouse_looking = true
	else:
		rotation = lerp_angle(self.rotation, DEFAULT_ANGLE, weight)
		is_mouse_looking = false

func _on_Player_hurt():
	health -= round(rand_range(3, 14))
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

#	bullet.velocity = target_pos - bullet.position // Bug fix, fun bug, maybe feature one day???

func _on_Player_hidden_changed(status):
	is_player_hidden = status
	Globals.player_hidden_status = status
	
	if status:
		player_graphic.texture = player_hidden
	else:
		player_graphic.texture = player	

# This is for melee
func _on_AttackBox_body_entered(body):
	if body.body_id == 1:
		melee_mode = true

func _on_AttackBox_body_exited(body):
	if body.body_id == 1:
		melee_mode = false

