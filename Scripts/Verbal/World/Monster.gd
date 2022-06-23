extends KinematicBody2D

signal unstunned

# Collision trackers
var is_player_in_body := false

# In development (Monster navigation)
# Speed is already declared
var path: Array = []
var levelNavigation: Navigation2D = null
var mapSet: TileMap = null
var player = null
var player_spotted: bool = false
var last_known_player_pos = Vector2.ZERO

onready var los = $LineOfSight
onready var line2d = $Line2D

# Monster variables
var speed := 75
var velocity: Vector2 = Vector2.ZERO
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
	yield(get_tree(), "idle_frame")
	var tree = get_tree()
	if tree.has_group("LevelNavigation"):
		levelNavigation = tree.get_nodes_in_group("LevelNavigation")[0]
	if tree.has_group("MapSet"):
		mapSet = tree.get_nodes_in_group("MapSet")[0]
	if tree.has_group("Player"):
		player = tree.get_nodes_in_group("Player")[0]

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

var rnd_cell: Vector2 = Vector2(-9999, -9999)
var nav_finished: bool = false

func _physics_process(delta):
	if !disable_movement:
		# Add an AI that allows for hunting, patroling, ect.

		# Trig is hard.
		# Experiment with different movement methods.
		
		#
#		move_and_slide(Vector2(cos(rotation), sin(rotation)) * speed) # Some work needs to be done.
#		rotation = lerp_angle(self.rotation, (Globals.player_pos - global_position).normalized().angle(), 0.1)
		# Navigation development
		line2d.global_position = Vector2.ZERO
		line2d.global_rotation = 0
		
		
		if !player_spotted && mapSet:
#			print(rnd_cell)
#			print(mapSet.get_cell(rnd_cell.x, rnd_cell.y))
			if mapSet.get_cell(rnd_cell.x, rnd_cell.y) != -1 && !nav_finished:
				generate_path(rnd_cell)
				navigate()
				movement()
			else:
				rnd_cell = Vector2(round(rand_range(-600, 1300)), round(rand_range(-600, 1300)))
		if player && levelNavigation:
			los.look_at(Globals.player_pos)
			movement()
			if !Globals.player_hidden_status:
				player_spotted = check_player_in_detection()
			if player_spotted:
				last_known_player_pos = Globals.player_pos
				generate_path(last_known_player_pos)
				navigate()

		Globals.monster_pos = global_position
		# 

#		look_at(Globals.player_pos)
#		disable_movement = false

# Navigation - In development
func check_player_in_detection() -> bool:
	var collider = los.get_collider()
	if collider && collider.is_in_group("Player"):
		player_spotted = true
		return true
	return false

func navigate():
	if path.size() > 0:
		velocity = position.direction_to(path[1]) * speed
		rotation = lerp_angle(self.rotation, (path[1] - global_position).normalized().angle(), 0.1)
#		look_at(path[1])
	if global_position == path[0]:
		path.pop_front()

func movement():
	velocity = move_and_slide(velocity)

func generate_path(position_to_travel):
	if levelNavigation != null && player != null:
		path = levelNavigation.get_simple_path(global_position, position_to_travel, false)
		line2d.points = path
#		last_known_player_pos = Globals.player_pos
	else:
		print("whoops")

func destroy_moster():
	queue_free()

func stun_monster(_TIME_STUNNED):
	if !is_stunned:
		TIME_STUNNED = _TIME_STUNNED
		is_stunned = true
		disable_movement = true
		player_spotted = false

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
