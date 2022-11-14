extends Node

const DEAFAULT_PORT : int = 50000
const MAX_CLIENTS : int = 6

var server = null
var client = null

var ip_address : String = ""

func _ready():
	ip_address = IP.get_local_addresses()[3]
	print("Found ip: " + ip_address)
	get_tree().connect("connected_to_server", self, "_connected_to_server")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self,"_player_disconnected")

func create_server() -> void:
	server = NetworkedMultiplayerENet.new()
	server.create_server(DEAFAULT_PORT, MAX_CLIENTS)
	get_tree().set_network_peer(server)
	print("Server created")

func join_server() -> void:
	client = NetworkedMultiplayerENet.new()
	client.create_client(ip_address, DEAFAULT_PORT)
	var result = get_tree().set_network_peer(client)
	print("Server joined with result:", result)

func _connected_to_server() -> void:
	print("Connected to server")
	Global.instance_player(get_tree().get_network_unique_id())

func _server_disconnected() -> void:
	print("Server kicked you")

func _player_connected(id: int):
	print("Player has connected: " + str(id))
	Global.instance_player(id)
	
func _player_disconnected(id: int):
	print("Player has disconnected: " + str(id))
	#Deal with disconneting
	if PersistentNodes.has_node(str(id)):
		PersistentNodes.get_node(str(id)).queue_free()
