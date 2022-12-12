extends Control

onready var kicked_popup = $KickedPopup
onready var player_disconnected_popup = $PlayerDisconnected

func _ready():
	Network.disconnect_from_network()
	if Network.has_server_kicked:
		kicked_popup.popup_centered()
		Network.has_server_kicked = false
	elif Network.has_player_disconnected:
		player_disconnected_popup.popup_centered()
		Network.has_player_disconnected = false


func _on_HostButton_pressed():
	get_tree().change_scene("res://UI/HostMenu.tscn")

func _on_QuitButton_pressed():
	get_tree().notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST) # see: https://docs.godotengine.org/en/stable/tutorials/inputs/handling_quit_requests.html

func _on_JoinButton_pressed():
	get_tree().change_scene("res://UI/JoinMenu.tscn")
	
