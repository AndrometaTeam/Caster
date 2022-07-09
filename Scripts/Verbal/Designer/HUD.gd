extends CanvasLayer

onready var Selected_Text = $Control/Selected/Text

func set_selected_text(text):
	Selected_Text.text = text
