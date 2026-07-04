extends Area2D

@onready var player

# var dialog = Dialogic.start("infoAreaExit")
# Dialogic will no longer be used due incompatability.

func _ready():
	# dialog.connect("timeline_end", Callable(self, "end_timeline"))
	pass

func _on_ActivateTimelineOneWay_body_entered(body):
	#add_child(dialog)
	pass
	player.is_movment_enabled = false
	player.position.y += 40

func end_timeline(timeline_name):
	pass
	print(timeline_name)
	if timeline_name == "timeline-1655972661.json":
		player.is_movment_enabled = true
