extends Control

onready var ip_label: Label = $VBoxContainer/ServerIP
onready var wait_for_host_label: Label = $WaitForHostLabel
onready var start_btn: Button = $StartBtn
onready var n_of_players_label = $VBoxContainer/NumberOfPlayers

onready var table: Tree = $VBoxContainer/Table

func _ready():
	GameState.connect("player_registered", self, "refresh_table")

	ip_label.text = "Server IP: %s" % Network.ip_address
	if not get_tree().is_network_server():
		start_btn.visible = false
		wait_for_host_label.visible = true
	refresh_table()

func set_up_table():
	table.clear()
	table.set_column_title(0, "Name")
	table.set_column_title(1, "Colour")
	# table.set_column_title(2, "id")
	var root = table.create_item()
	table.set_hide_root(true)
	
	# if not get_tree().is_network_server(): # for the future
	# 	table.columns = 4
	# 	table.set_column_title(3, "Kick")

	# var child1 = table.create_item(root)
	# child1.set_text_align(0, 1)
	# child1.set_text(0, "Jusk")
	# child1.set_custom_bg_color(1, Color(1, 0, 0, .9))
	# child1.set_text(2, "1")

func add_player_to_table(player_info):
	var player_row = table.create_item()
	player_row.set_text_align(0, 1)
	player_row.set_text(0, player_info["name"])
	player_row.set_custom_bg_color(1, player_info["colour"])
	

func refresh_table():
	set_up_table()
	add_player_to_table(GameState.my_info)
	for player_info in GameState.players_info.values():
		add_player_to_table(player_info)
	
	n_of_players_label.text = str(GameState.number_of_players)
	if GameState.number_of_players == 1:
		start_btn.visible = false
		n_of_players_label.text += " Player connected"
	else:
		if get_tree().is_network_server():
			start_btn.visible = true
		n_of_players_label.text += " Players connected"



func _on_BackBtn_pressed():
	Network.disconnect_from_network()
	get_tree().change_scene("res://UI/MainMenu.tscn")


func _on_StartBtn_pressed():
	GameState.start_game()
