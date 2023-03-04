extends Node

signal _data_recieved
signal _download_finished

var data : Dictionary

func get_connection():
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed", self, "_http_request_completed")

	# Perform the HTTP request.
	var error = http_request.request("https://www.google.com/")
	if error != OK:
		push_error("An error occurred in the HTTP request.")

func get_data(link: String):
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed", self, "_http_request_completed")
	connect("_data_recieved", self, "data_recieved")

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
	var data_parsed : Dictionary = str2var(PoolByteArray(body).get_string_from_ascii())
	data = data_parsed

func download(link, path):
	var http = HTTPRequest.new()
	add_child(http)
	http.connect("request_completed", self, "_http_request_dl_completed")
	

	http.set_download_file(path)
	var request = http.request(link)
	if request != OK:
		push_error("Http request error")

func _http_request_dl_completed(result, _response_code, _headers, _body):
	print_tree_pretty()
	
	
	if result != OK:
		push_error("Download Failed")
	emit_signal("_download_finished")
	remove_child($"./@@8")
	remove_child($"./@@6")
