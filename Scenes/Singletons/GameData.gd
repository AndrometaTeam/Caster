extends Node

var skilldata

func _ready(): # Early start messages.
	print("===== Made by KiloDev =====")
	print("This project is early and in development.")
	print("README: Visit the itch page for official builds!")
	print("Visit the github for official project developments.")
	print("Itch: https://andrometa.itch.io/caster")
	print("GitHub: https://github.com/KiloDev/Caster")
	print("=====  Kilo's dream   =====")
	
	var skilldata_file = File.new()
	skilldata_file.open("res://Data/SkillData.json", File.READ)
	var skilldata_json = JSON.parse(skilldata_file.get_as_text())
	skilldata_file.close()
	skilldata = skilldata_json.result
