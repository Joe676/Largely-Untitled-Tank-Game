extends Spatial


func _ready():
	var camera: InterpolatedCamera = get_tree().root.get_camera()
	var current_player = Players.get_node(str(get_tree().get_network_unique_id()))

	camera.set_target(current_player)
