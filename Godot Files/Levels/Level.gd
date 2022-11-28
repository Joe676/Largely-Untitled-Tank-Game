extends Spatial

onready var spawn_points = [
	$SpawnPoints/Point1,
	$SpawnPoints/Point2,
	$SpawnPoints/Point3,
	$SpawnPoints/Point4,
	$SpawnPoints/Point5,
	$SpawnPoints/Point6,
]

const camera_target_displaycement = Vector3(0, 20, -40)

func _ready():
	randomize()
	spawn_points.shuffle()
	Global.move_players_to_spawnpoints(spawn_points)

func _physics_process(_delta):
	hook_camera_to_player()

func hook_camera_to_player():
	var camera_target = $CameraTarget
	var current_player = PersistentNodes.get_node(str(get_tree().get_network_unique_id()))

	if current_player == null:
		return

	var player_position = current_player.global_translation
	
	camera_target.global_transform = current_player.global_transform
	camera_target.translate(camera_target_displaycement)
	
	camera_target.look_at(player_position, Vector3.UP)

