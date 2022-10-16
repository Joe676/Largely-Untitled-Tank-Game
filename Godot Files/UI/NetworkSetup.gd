extends Control

onready var multiplayer_config_ui = $MultiplayerConfigure
onready var server_ip_address = $MultiplayerConfigure/ServerIPAddressTxt

onready var device_ip_address = $CanvasLayer/DeviceIPAddressLbl

func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_to_server")

	device_ip_address.text = Network.ip_address

func _player_connected(id: int):
	print("Player has connected: " + str(id))
	
func _player_disconnected(id: int):
	print("Player has disconnected: " + str(id))

func _on_CreateServerBtn_pressed():
	multiplayer_config_ui.hide()
	Network.create_server()


func _on_JoinServerBtn_pressed():
	if server_ip_address.text != "":
		multiplayer_config_ui.hide()
		Network.ip_address = server_ip_address.text
		Network.join_server()
