extends GutTest

var player_scene
var location

func before_all():
	player_scene = load("res://Player/Tank.tscn")
	location = Vector3(10, 10, 10)

func after_each():
	Global.remove_all_children(PersistentNodes)

func test_instance_node():
	#Arrange
	var parent = Node.new()

	#Act
	var result: Node = Global.instance_node(player_scene, parent)

	#Assert
	assert_eq(result.get_parent(), parent, "Should have the provided node as the parent.")
	assert_true(result in parent.get_children(), "Should be a child of the parent.")


func test_instance_node_at_location():
	#Arrange
	var parent = Node.new()

	#Act
	var result: Spatial = Global.instance_node_at_location(player_scene, parent, location)

	#Assert
	assert_eq(result.get_parent(), parent, "Should have the provided node as the parent.")
	assert_eq(result.translation, location, "Should be at the provided location globally.")
	

func test_instance_node_with_transform():
	#Arrange
	var y_axis = Vector3(0, 1, 0)
	var rotation_angle = 3 #radians

	var transform = Transform()
	transform.translated(location)
	transform.rotated(y_axis, rotation_angle)

	#Act
	var result: Spatial = Global.instance_node_with_transform(player_scene, transform)

	#Assert
	assert_eq(result.transform, transform)


func test_instance_player():
	#Arrange
	var id: int = 1
	var server = NetworkedMultiplayerENet.new()
	server.create_server(2137, 1)
	get_tree().set_network_peer(server)

	#Act
	var result = Global.instance_player(id)

	#Assert
	assert_eq(result.name, str(id), "Should be named with the id.")
	assert_eq(result.get_parent(), PersistentNodes, "Should be saved in PersistentNodes.")
	assert_true(result.is_network_master(), "Should be the network master")
	assert_connected(result, GameState, "health_updated", "_player_health_changed")
	assert_connected(result, GameState, "died", "player_died")

	#Clean Up
	get_tree().set_network_peer(null)

func test_remove_all_children():
	#Arrange
	var parent = Node.new()

	var kids = [
		Node.new(),
		Node.new(),
		Node.new(),
		Node.new(),
		Node.new()
	]

	for kid in kids:
		parent.add_child(kid)
	
	#Act
	Global.remove_all_children(parent)

	#Assert
	assert_eq(parent.get_child_count(), 0, "Should have no children.")
	for kid in kids:
		assert_true(kid.is_queued_for_deletion())


func test_get_all_players():
	#Arrange
	var non_player = Node.new()
	var kids = [
		player_scene.instance(),
		player_scene.instance(),
		player_scene.instance(),
		player_scene.instance(),
		player_scene.instance(),
		non_player
	]
	var number_of_players = 5

	for kid in kids:
		PersistentNodes.add_child(kid)
	
	#Act
	var result = Global.get_all_players()
	
	#Assert
	assert_false(non_player in result, "Should not return anything but players.")
	assert_eq(result.size(), number_of_players, "Should have %d players." % number_of_players)
	
	
func test_strip_y_rotation():
	#Arrange
	var vector = Vector3(10, 10, 10)
	
	#Act
	var result = Global.strip_y_rotation(location)

	#Assert
	assert_eq(result.y, 0, "Should be two-dimensional.")
	assert_eq(result.x, vector.x, "Should be projected - x should still be the same.")
	assert_eq(result.z, vector.z, "Should be projected - z should still be the same.")
	assert_lt(result.length(), vector.length(), "Should be overall shorter after projection.")
	