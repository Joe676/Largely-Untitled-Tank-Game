extends Node

func instance_node_at_location(node:Object, parent:Object, location:Vector3):
	var node_instance = instance_node(node, parent)
	node_instance.transform.origin = location
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
	