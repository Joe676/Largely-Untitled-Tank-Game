extends Control


onready var multiplayer_config_ui = $MultiplayerConfigure
onready var server_ip_address = $MultiplayerConfigure/ServerIPAddressTxt

onready var device_ip_address = $CanvasLayer/DeviceIPAddressLbl

func _ready():
	device_ip_address.text = Network.ip_address

func _on_CreateServerBtn_pressed():
	multiplayer_config_ui.hide()
	Network.create_server()
	Global.instance_player(get_tree().get_network_unique_id())
	get_tree().change_scene("res://Levels/LevelProto.tscn")


func _on_JoinServerBtn_pressed():
	if server_ip_address.text != "":
		Network.ip_address = server_ip_address.text
		Network.join_server()
		multiplayer_config_ui.hide()
		get_tree().change_scene("res://Levels/LevelProto.tscn")

