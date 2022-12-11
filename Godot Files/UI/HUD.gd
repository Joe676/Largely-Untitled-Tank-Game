extends Control

onready var player_info_container = $PlayerInfoContainer
onready var player_info_scene = preload("res://UI/PlayerInfo.tscn")

var player_info_instances = {}

func _ready():
	GameState.connect("player_health_changed", self, "refresh_players_info")

func set_up_info():
	for player_id in GameState.players_info:
		var player_info = GameState.players_info[player_id]
		var info_instance = player_info_scene.instance()
		info_instance.get_node("Container/NameLabel").text = player_info["name"]
		var hbar = info_instance.get_node("Container/HealthBar")
		hbar.max_value = player_info["max_health"]
		hbar.value = player_info["current_health"]
		player_info_instances[player_id] = info_instance
		player_info_container.add_child(info_instance)


func refresh_players_info():
	for player_id in GameState.players_info:
		var player_info = GameState.players_info[player_id]
		if player_id in player_info_instances:
			var info_instance = player_info_instances[player_id]
			var hbar = info_instance.get_node("Container/HealthBar")
			hbar.max_value = player_info["max_health"]
			hbar.value = player_info["current_health"]
