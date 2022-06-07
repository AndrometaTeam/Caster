extends CanvasLayer

onready var TimeLabel = $GUI/HBoxContainer/VBoxContainer/MarginContainer/Labels/TimeLeft
onready var HealthLabel = $GUI/HBoxContainer/VBoxContainer/MarginContainer/Labels/Health
onready var StamLabel = $GUI/HBoxContainer/VBoxContainer/MarginContainer/Labels/Stamina
onready var AmmoLabel = $GUI/HBoxContainer/VBoxContainer/MarginContainer/Labels/Ammo


func _ready():
	Globals.connect("_player_hurt", self, "_on_Player_hurt")
	Globals.connect("_stamina_hurt", self, "_on_Stamina_drain")
	Globals.connect("_fire", self, "_on_Ammo_fire")
	Globals.connect("_player_ready", self, "_on_Player_ready")
	Globals.connect("_player_is_dead", self, "_on_Player_dead")
	Globals.connect("_no_ammo", self, "_on_Ammo_out")
	Globals.connect("_no_stam", self, "_on_Stamina_out")


# When gamemode is added
#func _on_TimeLeft_change():
#	pass
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

func _on_Stamina_drain():
	StamLabel.text = "Stamina: " + str(Globals.PlayerStamina)

func _on_Ammo_out():
	AmmoLabel.text = "Ammo: NO AMMO"

func _on_Ammo_fire():
	AmmoLabel.text = "Ammo: " + str(Globals.PlayerAmmo)
