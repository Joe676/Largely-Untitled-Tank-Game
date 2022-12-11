extends Control

onready var vp_label: Label = $GridContainer/HFlowContainer/VPSlider/CurrentVP
onready var name_input: LineEdit = $GridContainer/NameInput
onready var no_name_popup: AcceptDialog = $NoNameDialog
onready var colour_picker: ColorPickerButton = $GridContainer/ColorPickerButton

func _ready():
	var ip_label = $IPLbl
	ip_label.text = "Your IP: %s" % Network.ip_address 

func _on_VPSlider_value_changed(value: int):
	vp_label.text = str(value)
	GameState.vp_goal = value

func _on_StartBtn_pressed():
	var player_name = name_input.text
	if player_name == null or player_name == "": 
		no_name_popup.popup_centered()
		return
	player_name += " (host)"
	Network.create_server()
	Global.my_player_data["player_name"] = player_name
	GameState.my_info["name"] = player_name
	Global.my_player_data["player_colour"] = colour_picker.color
	GameState.my_info["colour"] = colour_picker.color
	Global.instance_player(get_tree().get_network_unique_id())
	Global.vp_goal = int(vp_label.text)
	
	get_tree().change_scene("res://UI/Lobby.tscn")
	

func _on_BackBtn_pressed():
	Network.disconnect_from_network()
	get_tree().change_scene("res://UI/MainMenu.tscn")

