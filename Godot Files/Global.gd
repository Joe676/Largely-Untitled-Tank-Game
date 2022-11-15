extends Node

enum GameState {IN_GAME, IN_MENU}

var game_state: int = GameState.IN_MENU

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
	
func name_networked_object(node: Node, creator_name: String, base_name: String) -> String:
	var node_name = base_name + creator_name + str(Network.networked_object_name_index)
	node.name = node_name
	Network.networked_object_name_index += 1
	return node_name