extends Control

var player = load("res://Player/TankProto.tscn")
var level = preload("res://Levels/LevelProto.tscn")

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
	instance_player(id)
	
func _player_disconnected(id: int):
	print("Player has disconnected: " + str(id))

	if Players.has_node(str(id)):
		Players.get_node(str(id)).queue_free()

func _on_CreateServerBtn_pressed():
	multiplayer_config_ui.hide()
	get_tree().change_scene("res://Levels/LevelProto.tscn")
	Network.create_server()
	yield(get_tree().create_timer(1), "timeout")

	instance_player(get_tree().get_network_unique_id())

func _on_JoinServerBtn_pressed():
	if server_ip_address.text != "":
		multiplayer_config_ui.hide()
		get_tree().change_scene("res://Levels/LevelProto.tscn")
		Network.ip_address = server_ip_address.text
		yield(get_tree().create_timer(1), "timeout")
		Network.join_server()

func _connected_to_server():
	yield(get_tree().create_timer(1), "timeout")
	instance_player(get_tree().get_network_unique_id())

func instance_player(id):
	var tanks_container = get_tree().root
	print(tanks_container)
	var player_instance = Global.instance_node_at_location(player, Players, Vector3(rand_range(-100, 100), 0, rand_range(-100, 100)))
	player_instance.name = str(id)
	player_instance.set_network_master(id)
