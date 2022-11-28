extends Control

onready var name_input: LineEdit = $NameInput
onready var ip_input: LineEdit = $IPInput
onready var no_name_popup: AcceptDialog = $NoNameDialog
onready var wrong_ip_popup: AcceptDialog = $WrongIPDialog
onready var colour_picker: ColorPickerButton = $ColorPickerButton

func _on_BackBtn_pressed():
	get_tree().change_scene("res://UI/MainMenu.tscn")

func _on_StartBtn_pressed():
	var player_name = name_input.text
	var ip = ip_input.text
	if player_name == null or player_name == "" or ip == null or ip == "": 
		no_name_popup.popup_centered()
		return
	# Network.ip_address = ip
	Global.my_player_data["player_name"] = player_name
	GameState.my_info["name"] = player_name
	Global.my_player_data["player_colour"] = colour_picker.color
	GameState.my_info["colour"] = colour_picker.color
	var was_created = Network.join_server(ip)
	if not was_created:
		wrong_ip_popup.popup_centered()
		return
	
	# get_tree().change_scene("res://Levels/LevelProto.tscn")
	get_tree().change_scene("res://UI/Lobby.tscn")
	
