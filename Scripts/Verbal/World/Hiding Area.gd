extends Area2D

func _on_Hiding_Area_body_entered(body):
	if body.collision_layer == 1: Globals.player_hide()
func _on_Hiding_Area_body_exited(body):
	if body.collision_layer == 1: Globals.player_hide(false)
