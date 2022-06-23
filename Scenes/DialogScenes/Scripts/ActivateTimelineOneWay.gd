extends Area2D

onready var player
var dialog = Dialogic.start("infoAreaExit")

func _ready():
	dialog.connect("timeline_end", self, "end_timeline")

func _on_ActivateTimelineOneWay_body_entered(body):
	add_child(dialog)
	player.is_movment_enabled = false
	player.position.y += 40

func end_timeline(timeline_name):
	print(timeline_name)
	if timeline_name == "timeline-1655972661.json":
		player.is_movment_enabled = true
