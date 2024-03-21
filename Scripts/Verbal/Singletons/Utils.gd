extends Node

signal _data_recieved
signal _download_finished

var data : Dictionary

func image_texture_loader(path: String) -> ImageTexture:
	var img = Image.new()
	var imageTexture: ImageTexture = ImageTexture.new()

	if (img.load(path) == OK):
		imageTexture.create_from_image(img)
		return imageTexture
	else:
		imageTexture.create(0,0, Image.FORMAT_RH)
		return imageTexture

func list_dir_contents(path: String, data_path: bool = false) -> Array:
	var contents: Array
	var dir = DirAccess.open(path)
	if dir != null:
		dir.list_dir_begin() # TODOGODOT4 fill missing arguments https://github.com/godotengine/godot/pull/40547
		var file_name = dir.get_next()
		while file_name != "":
			if !(dir.current_is_dir()):
				if !(data_path):
					contents.append(path + "/" + file_name)
				else:
					contents.append("data/tileset/" + file_name)
			file_name = dir.get_next()
		return contents
	else:
		print("An error occurred when trying to access the path..")
	return contents

func get_connection():
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed", Callable(self, "_http_request_completed"))

	# Perform the HTTP request.
	var error = http_request.request("https://www.google.com/")
	if error != OK:
		push_error("An error occurred in the HTTP request.")

func get_data(link: String):
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed", Callable(self, "_http_request_completed"))
	connect("_data_recieved", Callable(self, "data_recieved"))

	# Perform the HTTP request.
	var error = http_request.request(link)
	if error != OK:
		push_error("An error occurred in the HTTP request.")
		return "0"

func _http_request_completed(result, response_code, headers, body):	
	if (result == OK):
		emit_signal("_data_recieved", body)

func data_recieved(body):
#	print(PoolByteArray(body).get_string_from_ascii())
	var data_parsed : Dictionary = str_to_var(PackedByteArray(body).get_string_from_ascii())
	data = data_parsed

func download(link, path):
	var http = HTTPRequest.new()
	add_child(http)
	http.connect("request_completed", Callable(self, "_http_request_dl_completed"))
	http.get_downloaded_bytes()
	

	http.set_download_file(path)
	var request = http.request(link)
	if request != OK:
		push_error("Http request error")

func _http_request_dl_completed(result, _response_code, _headers, _body):
	if result != OK:
		push_error("Download Failed")
	emit_signal("_download_finished")
	remove_child($HTTPRequest)

#https://gist.github.com/KiloDev/18f3db2a3069e4e9ae7022918cb4e684
