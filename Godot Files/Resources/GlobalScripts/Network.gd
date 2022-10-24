extends Node

const DEAFAULT_PORT : int = 50000
const MAX_CLIENTS : int = 6

var server = null
var client = null

var ip_address : String = ""

func _ready():
	# if OS.name == "Windows":
	ip_address = IP.get_local_addresses()[3]
	print("Found ip: " + ip_address)
	
	get_tree().connect("connected_to_server", self, "_connected_to_server")
	get_tree().connect("server_disconnected", self, "_server_disconnected")

func create_server() -> void:
	server = NetworkedMultiplayerENet.new()
	server.create_server(DEAFAULT_PORT, MAX_CLIENTS)
	get_tree().set_network_peer(server)

func join_server() -> void:
	client = NetworkedMultiplayerENet.new()
	client.create_client(ip_address, DEAFAULT_PORT)
	get_tree().set_network_peer(client)

func _connected_to_server() -> void:
	print("Connected to server")
	Global.instance_player(get_tree().get_network_unique_id())

func _server_disconnected() -> void:
	print("Disconnected from server")
	

