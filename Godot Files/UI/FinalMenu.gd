extends Control

onready var podium_container = $PodiumContainer
onready var rest_container = $RestContainer

onready var single_standing_scene = preload("res://UI/SingleStanding.tscn")

func _ready():
	fill_standings()

func fill_standings():
	var all_players = []
	for player_info in GameState.players_info.values():
		all_players.append(player_info)
	all_players.append(GameState.my_info)

	all_players.sort_custom(self, "vp_comparison")

	for i in all_players.size():
		var player = all_players[i]
		var single_info = single_standing_scene.instance()
		single_info.get_node("Container/NameAndPlace/Name").text = player["name"] 
		single_info.get_node("Container/NameAndPlace/Placing").text = "#%d" % (i+1) 
		single_info.get_node("Container/VPLabel").text = "VP: %d" % player["vp"] 
		if i < 3:
			podium_container.add_child(single_info)
		else:
			rest_container.add_child(single_info)


func vp_comparison(a, b):
	return a["vp"] > b["vp"]

func _on_QuitBtn_pressed():
	Network.disconnect_from_network()
	get_tree().change_scene("res://UI/MainMenu.tscn")
