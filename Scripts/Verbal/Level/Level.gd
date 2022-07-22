extends Node2D

onready var map = $Nav/MapSet
onready var player_spawn = $PlayerSpawn

onready var player
onready var LevelData
onready var timeline_handle = $"Features/ActivateTimelineOneWay"


func _ready():
#	timeline_handle.player = player # I intend to make this more flexible in the future.
	map = str2var(LevelData.map_data)
	player_spawn = str2var(LevelData.player_spawn)
	print(player_spawn)
	player.global_position.x = player_spawn.x
	player.global_position.y = player_spawn.y
