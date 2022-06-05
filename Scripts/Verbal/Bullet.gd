extends Area2D

var max_range := 700
var speed := 750.0

var _travelled_distance = 0.0

func _physics_process(delta):
	var distance = speed * delta
	var motion = transform.x * speed * delta

	position += motion

	_travelled_distance += distance
	if _travelled_distance > max_range:
		queue_free()

func _on_Bullet_body_entered(body):
	if body.collision_layer == 2:
		Globals.stun_monster()
	queue_free()
	



# Bug fix, fun bug, maybe feature one day???

#extends KinematicBody2D
#
#var velocity = Vector2.ZERO
#var speed = 300
#
#func _physics_process(delta):
#	var collision_info = move_and_collide(velocity.normalized() * delta * speed)

