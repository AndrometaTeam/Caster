extends ColorRect

const CHUNK_SIZE = 1024

var exe_hash = "61336ec7d4707e9c5a47437a0f6945ec"
var pck_hash = "d9907f51b04dba92dd518200e45205ff"

#var unzip = load("res://addons/gdunzip/gdunzip.gd").new()

var metadata_Url = "https://gist.githubusercontent.com/KiloDev/8c5846de4570c2049520ae75bc9e3778/raw/metadata.json"

var patch_file = GameData.home_dir + "/patch/patch.dat"
var tmp_file = GameData.home_dir + "/.tmp"

@onready var Utility = $"../../../../LocalUtils"

# Set up data comparing and such.

#func _ready():
#	_calculate_info()
	
# target is where to save the file.
func download(url : String, target : String):
	var httpreq = HTTPRequest.new() # start the download
	add_child(httpreq)
	httpreq.set_download_file(target)
	
	httpreq.connect("request_completed", Callable(self, "request_complete"))
	var data = httpreq.request(url)
	
	if (data != OK):
		$Info.text = "Unable to grab patch files (*)"
		

func request_complete(result, _response_code, _headers, _body):
	if result != OK:
		$Info.text = "Unable to download update files (Report this to the itch page! [\"/andrometa/Caster\"])"
	else:
		caster_exe()

	
func _calculate_info():
	if !(OS.is_debug_build()):
		exe_hash = hash_file(GameData.home_dir + "/Caster.exe")
		pck_hash = hash_file(GameData.home_dir + "/Caster.pck")
		
		print(exe_hash)
		print(pck_hash)
		
	$Info.text = "Downloading metadata..."
	Utility.connect("_data_recieved", Callable(self, "data_return"))
	Utility.get_data(metadata_Url)

func hash_file(path) -> String:
	$Info.text = "Generating Hashes... [" + path + "]"
	var ctx = HashingContext.new()
	var file = FileAccess
	# Start a SHA-256 context.
	ctx.start(HashingContext.HASH_SHA256)
	# Check that file exists.
	if not file.file_exists(path):
		printerr("A file for the OBUS is missing.... :[")
		print(path)
		$Info.text = "A file is missing from your game directory, grabbing..."
		print(Utility.get_connection())
			
	
	# Open the file to hash.
	
	file = file.open(path, FileAccess.READ)
	# Update the context after reading each chunk.
	while not file.eof_reached():
		ctx.update(file.get_buffer(CHUNK_SIZE))
	# Get the computed hash.
	ctx.finish()
	
	#Returns the MD5 hash of the file.
	return file.get_md5(path)

func data_return(body):
	var data_parsed : Dictionary = str_to_var(PackedByteArray(body).get_string_from_ascii())
	
	
	
	if FileAccess.file_exists(tmp_file) or FileAccess.file_exists(GameData.home_dir + "/patch.tmp"):
		$Info.text = "Clearing game directory..."
		DirAccess.open(GameData.home_dir).remove(tmp_file)
		DirAccess.open(GameData.home_dir).remove("/patch.tmp")
	
	if FileAccess.file_exists(patch_file):
		$Info.text = "Clearing patch directory..."
		DirAccess.open(GameData.home_dir).remove(patch_file)
	elif (DirAccess.open(GameData.home_dir + "/patch/")) != null:
		$Info.text = "Generating patch directory..."
		DirAccess.open(GameData.home_dir).make_dir("/patch/")
	
	$Info.text = "Validating files..."
	if (exe_hash != data_parsed["Caster_exe"][0]["hash"]):
		$Info.text = "Grabbing patch file... This could take a while."
		
		download(data_parsed["Caster_exe"][0]["Link"], patch_file)
	
	elif (pck_hash != data_parsed["Caster_pck"][0]["hash"]):
		$Info.text = "Grabbing file... [PCK]"
		download(data_parsed["Caster_pck"][0]["Link"], patch_file)
	elif (OS.is_debug_build()):
		$Info.text = "Developer build detected!"
		$Info.text = "Grabbing patch file... This could take a while."
		download(data_parsed["Caster_exe"][0]["Link"], patch_file)
		

func caster_exe():
	
	$Info.text = "Patching..."
	
	var zr = ZIPReader.new()
	
	var file: FileAccess
	var loaded = zr.open(patch_file)
	if loaded != OK:
		print("Error Occured! Unable to update.")
		$Info.text = "Error decompresssing data!"
	
	if !zr.file_exists("Caster.exe"):
		print("No patch data was found!")
		$Info.text = "Error decompresssing data!"
		return
	
	print("hm")
	file = FileAccess.open(GameData.home_dir + "/patch.tmp", FileAccess.WRITE) # I've concluded this is causing application hangs / crashes.
	file.store_buffer(zr.read_file("Caster.exe", false))
	file.close()
	print("h2m")

func download_failed():
	$Info.text = "Download failed..."

func _on_Update_pressed():
	self.visible = !self.visible
	$"../../Start".disabled = self.visible
	_calculate_info()
