extends Node

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
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin(true, true)
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
