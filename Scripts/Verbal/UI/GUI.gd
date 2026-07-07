extends CanvasLayer

@onready var TimeLabel = $RootGUI/HBoxContainer/VBoxContainer/MarginContainer/Labels/TimeLeft
@onready var HealthLabel = $RootGUI/HBoxContainer/VBoxContainer/MarginContainer/Labels/Health
@onready var StamLabel = $RootGUI/HBoxContainer/VBoxContainer/MarginContainer/Labels/Stamina
@onready var AmmoLabel = $RootGUI/HBoxContainer/VBoxContainer/MarginContainer/Labels/Ammo


func _ready():
	Globals.connect("_player_hurt", Callable(self, "_on_Player_hurt"))
	Globals.connect("_stamina_changed", Callable(self, "_on_Stamina_changed"))
	Globals.connect("_fire", Callable(self, "_on_Ammo_changed"))
	Globals.connect("_player_ready", Callable(self, "_on_Player_ready"))
	Globals.connect("_player_is_dead", Callable(self, "_on_Player_dead"))
	Globals.connect("_no_ammo", Callable(self, "_on_Ammo_out"))
	Globals.connect("_no_stam", Callable(self, "_on_Stamina_out"))

	if GameData.cmdk_enabled:
		Cmdk.ui_update.connect(_ui_update)


# When gamemode is added
#func _on_TimeLeft_change():
#	pass
func _ui_update():
	print("UI_UPDATE")
	_on_Ammo_changed()
	_on_Stamina_changed()
	_on_Player_hurt()

func _on_Player_ready():
	HealthLabel.text = "Health: " + str(Globals.PlayerHealth)
	StamLabel.text = "Stamina: " + str(Globals.PlayerStamina)
	AmmoLabel.text = "Ammo: " + str(Globals.PlayerAmmo)

func _on_Player_dead():
	HealthLabel.text = "Health: DEAD"

func _on_Player_hurt():
	HealthLabel.text = "Health: " + str(Globals.PlayerHealth)

func _on_Stamina_out():
	StamLabel.text = "Stamina: NO STAMINA"

func _on_Ammo_out():
	AmmoLabel.text = "Ammo: NO AMMO"

func _on_Stamina_changed():
	StamLabel.text = "Stamina: " + str(Globals.PlayerStamina)

func _on_Ammo_changed():
	AmmoLabel.text = "Ammo: " + str(Globals.PlayerAmmo)
