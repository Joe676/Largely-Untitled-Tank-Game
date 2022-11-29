extends Node

signal player_registered
signal start_game
signal player_health_changed

onready var number_of_players: int = 1
var dead_players = []

var vp_goal: int = 1

onready var players_info: Dictionary = {}

onready var my_info: Dictionary = {name = "", colour = Color(1, 0, 0, 1), vp = 0, current_health = 100, max_health = 100}

enum State {IN_LOBBY, IN_GAME, GAME_STOPPED}

onready var state = State.IN_LOBBY

func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	pass

func _player_connected(id):
	number_of_players += 1
	rpc_id(id, "register_player", my_info)

remote func register_player(info):
	var id = get_tree().get_rpc_sender_id()

	players_info[id] = info
	emit_signal("player_registered")

func start_game():
	get_tree().get_network_peer().refuse_new_connections = true
	state = State.IN_GAME
	emit_signal("start_game")
	# for peer in get_tree().get_network_connected_peers():
	# 	print("peer: ", peer)
	rpc("remote_start_game")
	start_round()

remote func remote_start_game():
	state = State.IN_GAME
	emit_signal("start_game")
	# start_round()
	
func _player_health_changed(id, new_value, max_value):
	if id in players_info:
		players_info[id]["current_health"] = new_value
		players_info[id]["max_health"] = max_value
		emit_signal("player_health_changed")
	
func player_died(id):
	if get_tree().is_network_server():
		dead_players.append(id)
		print("dead_players: ", dead_players)
		if dead_players.size() == number_of_players-1:
			print("Last man standing!")
			finish_round()

func finish_round():
	state = State.GAME_STOPPED
	rpc("remote_finish_round")
	get_tree().change_scene("res://UI/WaitingMenu.tscn")
	pass

remote func remote_finish_round():
	state = State.GAME_STOPPED
	get_tree().change_scene("res://UI/WaitingMenu.tscn")
	pass

func start_round():
	state = State.IN_GAME
	rpc("remote_start_round")
	get_tree().change_scene("res://Levels/LevelProto.tscn")

remote func remote_start_round():
	state = State.IN_GAME
	get_tree().change_scene("res://Levels/LevelProto.tscn")
