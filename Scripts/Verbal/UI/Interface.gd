extends CanvasLayer

func _ready():
	Globals.connect("_is_counting", Callable(self, "_on_Counter_changed"))
	Globals.connect("monster_spawn", Callable(self, "_on_Counter_changed"))
	Globals.connect("_player_ready", Callable(self, "_on_Player_ready"))

func _on_Player_ready():
	$RootUI/Label.text = "Counter: " + str(round(Globals.monster_counter))

func _on_Counter_changed(): # Probably way better
	$RootUI/Label.text = "Counter: " + str(round(Globals.monster_counter))
