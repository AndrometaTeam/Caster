extends Node2D

onready var map = $Nav/MapSet
onready var player_spawn = $PlayerSpawn

onready var player
onready var MapData
onready var timeline_handle = $"Features/ActivateTimelineOneWay"


func _ready():
#	timeline_handle.player = player # I intend to make this more flexible in the future.
	map = MapData.map_data
	player_spawn = MapData.player_spawn


