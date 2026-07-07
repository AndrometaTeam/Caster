extends Node

@warning_ignore("unused_signal")
signal ui_update

# Variable for the Loader
var mod_ids: Array[int]
var load_order: Array[int]
var mod_nodes: Array[Node]
var mod_cache: Array[Node]
var ModRoot: Node2D

# Variables for the API
var Level: Node2D
var map
var player_ptr
#Cmdk._expose_references(instanced_scene)

## Loads each mod by ID in order and adds them to the scene tree (This activates them).
func load_mods_ordered() -> Array[Node]:
	mod_nodes.clear()
	
	# As of right now this may cause issues with blacklisting mods, specifically, mods may load partially.
	# This depends on how invasive they are to the scene tree.
	# I think this is okay as some mods may primarily be QoL or affect non-map related nodes.
	# Those that invade map related nodes will be tricky to deal with (kinda).
	
	for mod in load_order:
		mod_nodes.append(load_mod(mod))
	
	return mod_nodes

func load_mod(mod_id: int) -> Node:
	ModRoot.add_child(mod_cache[mod_id])
	return mod_cache[mod_id]

func load_mod_cache():
	var mod_dir := DirAccess.open(GameData.mods_dir)
	var mod_id: int = 0
	
	for mod in mod_dir.get_directories():
		if !FileAccess.open(GameData.mods_dir + mod + "/mod.tscn", FileAccess.READ):
			continue
		
		var mod_scene_packed: PackedScene = load(GameData.mods_dir + mod + "/mod.tscn")
		var mod_scene = mod_scene_packed.instantiate()
		
		mod_scene.name = mod
		mod_cache.append(mod_scene)
		mod_ids.append(mod_id)
		load_order.append(mod_id) # This should be user selected later.
		
		print(mod)
		mod_id = mod_id + 1

# Add a function for map creators to block mods
# from loading.

func set_mdk_references(player):
	player_ptr = player

## Initializes the MDK
func _init_mdk(script_scene) -> void:
	if GameData.cmdk_enabled:
		_expose_references(script_scene)
		map = script_scene

func _expose_references(mapnode: Node):
	if mapnode.has_method("_player_hook"):
		mapnode._player_hook(player_ptr)
	if mapnode.has_method("_mod_hook"):
		for mod in load_mods_ordered():
			if mod == null:
				continue
			mapnode._mod_hook(mod)
