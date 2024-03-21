extends Label


func _ready():
	# Create an HTTP request node and connect its completion signal.
	var http_request = HTTPRequest.new()
	add_child(http_request)
#	if (OS.is_debug_build()):
	http_request.connect("request_completed", Callable(self, "_http_request_completed"))

#	Perform the HTTP request. The URL below returns a PNG image as of writing.
	var error = http_request.request("https://gist.githubusercontent.com/KiloDev/18f3db2a3069e4e9ae7022918cb4e684/raw/9c244b8afb315f6021369d1ad1e34d3c796a8458/Caster.json")
	if error != OK:
		push_error("An error occurred in the HTTP request.")


func _grab_gist():
	pass





# Called when the HTTP request is completed.
func _http_request_completed(result, response_code, headers, body):
#	print(PoolByteArray(body).get_string_from_ascii())
	
	if (result == 3):
		self.text = "Could not resolve host | Current build: " + str(GameData.build_version)
		$"../../../Update".disabled = true
	
	elif (result == OK):
		var data : Dictionary = str_to_var(PackedByteArray(body).get_string_from_ascii())
		var obuild = data.build_version

		if (GameData.build_version < obuild):
			self.text = "Current build: " + str(GameData.build_version) + " | Build: " + str(obuild) + " is avaliable!"
			$"../../../Update".disabled = false
		elif (GameData.build_version > obuild):
			self.text = "Current build: " + str(GameData.build_version) + " | Development build!"
			$"../../../Update".disabled = true
		elif (GameData.build_version == obuild):
			self.text = "Current build: " + str(GameData.build_version) + " | You're up to date!"
			$"../../../Update".disabled = true
	else:
		self.text = "Could not get latest version | Current build: " + str(GameData.build_version)
		$"../../../Update".disabled = true
	
	


