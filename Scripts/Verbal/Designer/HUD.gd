extends CanvasLayer

# Signals
signal focus_changed
signal hide_inspector
signal level_name_changed

onready var Selected_Text = $Control/Selected/Text
onready var Controls = $Control/Controls
onready var Selected = $Control/Selected
onready var Inspector = $Control/Ispector

func _ready():
	connect("hide_inspector", self, "hideinspector")
	
	
	
	$Control.focus_mode = Control.FOCUS_ALL

func set_selected_text(text):
	Selected_Text.text = text

func _process(delta):
	if (Input.is_action_just_pressed("func1")):
		Controls.visible = !Controls.visible

func hideinspector():
	Inspector.visible = !Inspector.visible

func _on_lvlName_focus_entered():
	emit_signal("focus_changed", true)


func _on_lvlName_focus_exited():
	emit_signal("focus_changed", false)


func _on_lvlName_text_changed(new_text):
	emit_signal("level_name_changed", new_text)
