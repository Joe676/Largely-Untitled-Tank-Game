extends Node

onready var my_player_data: Dictionary = {
	"player_name": "",
	"player_colour": Color.blue
}

var vp_goal = 3

func instance_node_at_location(node:Object, parent:Object, location:Vector3):
	var node_instance = instance_node(node, parent)
	node_instance.transform.origin = location
	return node_instance
	
func instance_node_with_transform(node:Object, node_transform:Transform):
	var node_instance = node.instance()
	node_instance.transform = node_transform
	return node_instance

func instance_node(node:Object, parent:Object)->Object:
	var node_instance = node.instance()
	parent.add_child(node_instance)
	return node_instance

func instance_player(id):
	var player = load("res://Player/TankProto.tscn")
	var player_instance = Global.instance_node_at_location(player, PersistentNodes, Vector3(rand_range(-10, 10), 0, rand_range(-10, 10)))
	player_instance.name = str(id)
	player_instance.set_network_master(id)
	if player_instance.is_network_master():
		player_instance.player_name = my_player_data["player_name"]
		player_instance.player_colour = my_player_data["player_colour"]
	player_instance.connect("health_updated", GameState, "_player_health_changed")
	player_instance.connect("died", GameState, "player_died")
	player_instance.set_up()
	
func name_networked_object(node: Node, creator_name: String, base_name: String) -> String:
	var node_name = base_name + creator_name + str(Network.networked_object_name_index)
	node.name = node_name
	Network.networked_object_name_index += 1
	return node_name

func move_players_to_spawnpoints(spawn_points):
	if get_tree().is_network_server():
		var players = PersistentNodes.get_children()
		var player_idx = 0
		for point in spawn_points:
			if player_idx >= players.size():
				return
			var player = players[player_idx]
			while not player.has_method("is_player"):
				player_idx += 1
				if player_idx >= players.size():
					return
				player = players[player_idx]
			player.move_to_spawn_point(point.global_transform)
			player_idx += 1

static func remove_all_children(node):
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()

func get_all_players():
	var all_nodes = PersistentNodes.get_children()
	var output = []
	for node in all_nodes:
		if node.has_method("is_player"):
			output.append(node)
	return output