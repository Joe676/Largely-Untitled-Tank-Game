extends Node

signal player_registered
signal start_game
signal start_round
signal player_health_changed
signal selected_card(card)

onready var number_of_players: int = 1
var dead_players = []
var waiting_for: int = 0

var vp_goal: int = 3
var last_winner_id: String = ""

onready var players_info: Dictionary = {}

onready var my_info: Dictionary = {name = "", colour = Color(1, 0, 0, 1), vp = 0, current_health = 100, max_health = 100}

enum NextPhase {INTERMISSION, FINISH}
enum State {IN_LOBBY, IN_GAME, GAME_STOPPED}

onready var state = State.IN_LOBBY

func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self,"_player_disconnected")

func _player_connected(id):
	number_of_players += 1
	rpc_id(id, "register_player", my_info)

func _player_disconnected(id):
	number_of_players -= 1
	players_info.erase(id)
	emit_signal("player_registered")
	

remote func register_player(info):
	var id = get_tree().get_rpc_sender_id()

	players_info[id] = info
	emit_signal("player_registered")

func start_game():
	get_tree().get_network_peer().refuse_new_connections = true
	state = State.IN_GAME
	emit_signal("start_game")
	rpc("remote_start_game", vp_goal)
	start_round()

remote func remote_start_game(vp):
	vp_goal = vp
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
		if dead_players.size() == number_of_players-1:
			finish_round()

func finish_round():
	last_winner_id = find_winner()
	state = State.GAME_STOPPED
	rpc("set_last_winner", last_winner_id)
	add_vp()
	if last_winner_won_game():
		rpc("remote_finish_round", NextPhase.FINISH, [])
		get_tree().change_scene("res://UI/FinalMenu.tscn")
		return

	var worst_players = get_worst_players()
	waiting_for = worst_players.size()
	rpc("remote_finish_round", NextPhase.INTERMISSION, worst_players)
	if 1 in worst_players or "1" in worst_players:
		get_tree().change_scene("res://UI/CardsMenu.tscn")
		return
	get_tree().change_scene("res://UI/WaitingMenu.tscn")

remote func remote_finish_round(nextPhase, worst_players: Array):
	state = State.GAME_STOPPED
	if nextPhase == NextPhase.FINISH:
		get_tree().change_scene("res://UI/FinalMenu.tscn")
	elif worst_players.has(get_tree().get_network_unique_id()):
		get_tree().change_scene("res://UI/CardsMenu.tscn")
	else:
		get_tree().change_scene("res://UI/WaitingMenu.tscn")

func start_round():
	state = State.IN_GAME
	dead_players = []
	emit_signal("start_round")
	rpc("remote_start_round")
	# get_tree().change_scene("res://Levels/LevelProto.tscn")
	get_tree().change_scene("res://Levels/Level.tscn")

remote func remote_start_round():
	state = State.IN_GAME
	emit_signal("start_round")
	# get_tree().change_scene("res://Levels/LevelProto.tscn")
	get_tree().change_scene("res://Levels/Level.tscn")

remote func set_last_winner(id):
	last_winner_id = str(id)
	add_vp()

func find_winner() -> String:
	for id in players_info:
		if not dead_players.has(str(id)):
			return id
	return str(get_tree().get_network_unique_id())

func get_last_winner_data():
	if int(last_winner_id) in players_info:
		return players_info[int(last_winner_id)]
	elif last_winner_id == str(get_tree().get_network_unique_id()):
		return my_info

func add_vp():
	if int(last_winner_id) in players_info:
		players_info[int(last_winner_id)]["vp"] += 1
	elif last_winner_id == str(get_tree().get_network_unique_id()):
		my_info["vp"] += 1

func get_worst_players() -> Array:
	var output = []
	var min_points = vp_goal
	if my_info["vp"] < min_points:
		min_points = my_info["vp"]
		output.append(get_tree().get_network_unique_id())
	for player_id in players_info:
		var player = players_info[player_id]
		if player["vp"] == min_points:
			output.append(player_id)
		elif player["vp"] < min_points:
			output = [player_id]
			min_points = player["vp"]
	return output

func last_winner_won_game():
	return get_last_winner_data()["vp"] == vp_goal

func selected_card(card):
	emit_signal("selected_card", card)
	if get_tree().is_network_server():
		server_selected_card()
	else:
		rpc_id(1, "server_selected_card")
	get_tree().change_scene("res://UI/WaitingMenu.tscn")

remote func server_selected_card():
	waiting_for -= 1
	if waiting_for == 0:
		yield(get_tree().create_timer(2), "timeout")
		start_round()

func clear_players():
	players_info.clear()