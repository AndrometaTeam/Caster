extends Node

var map
var player_ptr

func _expose_references(mapnode: Node):
	map = mapnode
	
	if mapnode.has_method("_player_hook"):
		mapnode._player_hook(player_ptr)
