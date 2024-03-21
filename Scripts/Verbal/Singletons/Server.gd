extends Node

var network = ENetMultiplayerPeer.new()
var ip = "127.0.0.1"
var port = 1989

func _ready():
	pass
#	ConnectToServer()

func ConnectToServer():
	pass
	network.create_client(ip, port)
	get_tree().set_multiplayer_peer(network)
	
	network.connect("connection_failed", Callable(self, "_OnConnectionFailed"))
	network.connect("connection_succeeded", Callable(self, "_OnConnectionSucceeded"))
	

func _OnConnectionFailed():
	print("Failed to connect")

func _OnConnectionSucceeded():
	print("Successfully connected")
