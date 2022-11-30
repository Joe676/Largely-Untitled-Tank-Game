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
		# print("dead_players: ", dead_players)
		if dead_players.size() == number_of_players-1:
			# print("Last man standing!")
			finish_round()

func finish_round():
	# print("Finishing round")
	last_winner_id = find_winner()
	# print("the winner is: ", last_winner_id)
	rpc("set_last_winner", last_winner_id)
	add_vp()
	if last_winner_won_game():
		# print("We have a winner!")
		rpc("remote_finish_round", NextPhase.FINISH, [])
		get_tree().change_scene("res://UI/FinalMenu.tscn")
		return

	state = State.GAME_STOPPED

	var worst_players = get_worst_players()
	waiting_for = worst_players.size()
	# print("worst players: ", worst_players)
	rpc("remote_finish_round", NextPhase.INTERMISSION, worst_players)
	if 1 in worst_players or "1" in worst_players:
		print("WTH")
		get_tree().change_scene("res://UI/CardsMenu.tscn")
		return
	get_tree().change_scene("res://UI/WaitingMenu.tscn")

remote func remote_finish_round(nextPhase, worst_players: Array):
	print("remote_finish_round")
	# print("this player and the worst players: ", get_tree().get_network_unique_id(), worst_players)
	# print("is he in the worst? ", worst_players.has(get_tree().get_network_unique_id()))
	state = State.GAME_STOPPED
	if nextPhase == NextPhase.FINISH:
		# print("FINISH game")
		get_tree().change_scene("res://UI/FinalMenu.tscn")
	elif worst_players.has(get_tree().get_network_unique_id()):
		# print("open cards")
		get_tree().change_scene("res://UI/CardsMenu.tscn")
	else:
		# print("just wait")
		get_tree().change_scene("res://UI/WaitingMenu.tscn")

func start_round():
	state = State.IN_GAME
	dead_players = []
	emit_signal("start_round")
	rpc("remote_start_round")
	get_tree().change_scene("res://Levels/LevelProto.tscn")

remote func remote_start_round():
	state = State.IN_GAME
	emit_signal("start_round")
	get_tree().change_scene("res://Levels/LevelProto.tscn")

remote func set_last_winner(id):
	# print("remote setting last winner")
	last_winner_id = id
	add_vp()

func find_winner() -> String:
	for id in players_info:
		if not dead_players.has(str(id)):
			return id
	return str(get_tree().get_network_unique_id())

func get_last_winner_data():
	# print("get_last_winner: ", last_winner_id)
	if last_winner_id in players_info:
		return players_info[last_winner_id]
	elif last_winner_id == str(get_tree().get_network_unique_id()):
		return my_info

func add_vp():
	if last_winner_id in players_info:
		players_info[last_winner_id]["vp"] += 1
		# print("new winner vp: ", players_info[last_winner_id]["vp"])
	elif last_winner_id == str(get_tree().get_network_unique_id()):
		my_info["vp"] += 1
		# print("new winner vp: ", my_info["vp"])

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
	print("last winner won?: ", get_last_winner_data(), vp_goal)
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
		yield(get_tree().create_timer(5), "timeout")
		start_round()
