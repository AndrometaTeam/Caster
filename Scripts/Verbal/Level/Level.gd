extends Node2D

onready var map = $Nav/MapSet

#onready var tile_ids: Array = []
#onready var tile_positions = map.get_used_cells()
onready var player
onready var timeline_handle = $"Features/ActivateTimelineOneWay"

func _ready():
	timeline_handle.player = player # I intend to make this more flexible in the future.

# Me: Trying to make something for an AI algorithm and failing.
#	calculate_ids()
#
#
#func calculate_ids():
#
#	for i in tile_positions.size():
#		tile_ids.append(map.get_cellv(tile_positions[i]))
#	for x in tile_ids.size():
#		print(tile_ids[x])

