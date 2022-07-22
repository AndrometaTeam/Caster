extends CanvasLayer

onready var Selected_Text = $Control/Selected/Text

func set_selected_text(text):
	Selected_Text.text = text

func _process(delta):
	if (Input.is_action_just_pressed("func1")):
		$Control/Controls.visible = !$Control/Controls.visible
