extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	Globals.connect("_is_counting", self, "_on_Counter_changed")
	Globals.connect("monster_spawn", self, "_on_Counter_changed")
	Globals.connect("_player_ready", self, "_on_Player_ready")

func _on_Player_ready():
	$Label.text = "Counter: " + str(round(Globals.monster_counter))

func _on_Counter_changed(): # Probably way better
	$Label.text = "Counter: " + str(round(Globals.monster_counter))
