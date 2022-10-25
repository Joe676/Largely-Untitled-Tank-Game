extends Spatial

const camera_target_displaycement = Vector3(0, 20, -40)

func _ready():
	var current_player = Players.get_node(str(get_tree().get_network_unique_id()))


func _physics_process(delta):
	var camera_target = $CameraTarget
	# var camera: InterpolatedCamera = get_tree().root.get_camera()
	var current_player = Players.get_node(str(get_tree().get_network_unique_id()))

	if current_player == null:
		return

	var player_position = current_player.global_translation
	# var player_back_direction = current_player.transform.basis.z
	
	camera_target.global_transform = current_player.global_transform
	camera_target.translate(camera_target_displaycement)
	
	camera_target.look_at(player_position, Vector3.UP)

	# camera.look_at(current_player.global_translation, Vector3.UP)

