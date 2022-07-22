extends Sprite

var snap_size : Vector2 = Vector2(32, 32)
var mouse_pos : Vector2 = Vector2.ZERO

func _physics_process(delta):
	update_position_snapped()

func update_position_snapped():
	pass
	mouse_pos = Vector2(int(get_global_mouse_position().x / snap_size.x), 
						int(get_global_mouse_position().y / snap_size.y))
	
	global_position = mouse_pos * snap_size.x
