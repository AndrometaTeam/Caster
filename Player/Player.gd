extends KinematicBody2D

const body_id = 0

const ACCELERATION = 595
const FRICTION = 595
const ABSOLUTE_MAX_SPEED = 240 #Unchangable speed cap
const ABSOLUTE_WALKING_SPEED = 145
const DEFAULT_ANGLE = -1.5708
var SPEED = 145 #Allow for faster movements

var weight = 0.5
var target_pos = Vector2.ZERO
var velocity = Vector2.ZERO

#Other interesting fun things to test and play with.
var health = 100
var stamina = 100
var is_player_hidden = false #Add hiding feature to get away from the monster.

#Physically physical.
onready var Collider2D = $CollisionShape2D

#Bullet
const bullet_scene = preload("res://Scenes/ObjectScenes/Bullet.tscn")
var bullet_speed = 20

#Controls stuff
var is_mouse_looking = false

func _ready():
	Globals.connect("player_is_dead", self, "_on_Player_died")

func _physics_process(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	if input_vector != Vector2.ZERO:
		velocity = velocity.move_toward(input_vector * SPEED, ACCELERATION * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	velocity = move_and_slide(velocity)
	target_pos = get_global_mouse_position()
	Globals.player_pos = position
	
	if Input.is_action_pressed("sprint"):
		_player_speed(ABSOLUTE_MAX_SPEED)
	else:
		_player_speed(ABSOLUTE_WALKING_SPEED)
	
	if Input.is_action_pressed("right_nouse"):
		_mouse_look_function(true)
	elif Input.is_action_pressed("reset_mouse"):
		_mouse_look_function(false)
	else:
		is_mouse_looking = false

	if Input.is_action_just_pressed("left_mouse") and is_mouse_looking == true:
		shoot()
	
	$BulletRoot.look_at(target_pos) # Set to player position.
# Set rotation of bullet root to the rotation of the player.
#	look_at(target_pos) // Alternative for mouse look features.

func _player_speed(speed):
	SPEED = speed

func _mouse_look_function(is_looking):
	if is_looking:
		rotation = lerp_angle(self.rotation, (target_pos - global_position).normalized().angle(), weight)
		is_mouse_looking = true
	else:
		rotation = lerp_angle(self.rotation, DEFAULT_ANGLE, weight)
		is_mouse_looking = false

func _on_Player_died():
	print("I died")

func shoot(): #Shooting to stun the monster.
	var bullet = bullet_scene.instance()
	
	get_parent().add_child(bullet)
	bullet.position = $BulletRoot/Position2D.global_position
	bullet.rotation = rotation - bullet.rotation
	
#	bullet.velocity = target_pos - bullet.position // Bug fix, fun bug, maybe feature one day???
