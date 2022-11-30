extends Control

onready var single_standing_scene = preload("res://UI/SingleStanding.tscn")
onready var standings_container = $StandingsContainer

onready var winner_label = $WinnerLabel
const winner_text: String = "Last round's winner: "

func _ready():
	winner_label.text = winner_text + GameState.get_last_winner_data()["name"]
	fill_standings()
	# if get_tree().is_network_server():
	# 	yield(get_tree().create_timer(3), "timeout")
	# 	GameState.start_round()

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
		standings_container.add_child(single_info)



func vp_comparison(a, b):
	return a["vp"] > b["vp"]
