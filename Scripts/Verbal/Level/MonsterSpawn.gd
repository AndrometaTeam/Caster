extends Position2D

export var player_spawn := false

# This script is not useful yet, will be added once a level editor is made.

func _ready():
	if player_spawn: Globals.monster_pos = self.global_position
