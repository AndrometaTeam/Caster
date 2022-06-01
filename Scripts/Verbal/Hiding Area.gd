extends Area2D

func _on_Hiding_Area_body_entered(body):
	if body.body_id == 0: Globals.player_hide()


func _on_Hiding_Area_body_exited(body):
	if body.body_id == 0: Globals.player_hide(false)
