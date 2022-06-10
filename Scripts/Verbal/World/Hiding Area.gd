extends Area2D

export var player_spawn := false

func _ready():
	if player_spawn: Globals.player_pos = self.position

func _on_Hiding_Area_body_entered(body):
	if body.collision_layer == 1: Globals.player_hide()
func _on_Hiding_Area_body_exited(body):
	if body.collision_layer == 1: Globals.player_hide(false)
