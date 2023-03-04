extends Sprite

var snap_size : Vector2 = Vector2(32, 32)
var mouse_pos : Vector2 = Vector2.ZERO

#func _physics_process(delta):
#	update_position_snapped()
#	var mouse_pos = world_to_map(get_global_mouse_position())
#	global_position = map_to_world(mouse_pos)
#
#func update_position_snapped():
#	mouse_pos = Vector2(int(get_global_mouse_position().x / snap_size.x), 
#						int(get_global_mouse_position().y / snap_size.y))
#
#	global_position = mouse_pos * snap_size.x
