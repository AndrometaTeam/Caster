extends Node

var skilldata

func _ready():
	var skilldata_file = File.new()
	skilldata_file.open("res://Data/SkillData.json", File.READ)
	var skilldata_json = JSON.parse(skilldata_file.get_as_text())
	skilldata_file.close()
	skilldata = skilldata_json.result
