extends KinematicBody

onready var tween = $Tween

export (PackedScene) var bullet_scene

export var max_angular_velocity = 40
export var max_speed = 10

var velocity: Vector3
var angular_velocity: int

# var body_transform = Vector3()
# var head_transform = Vector3()

puppet var puppet_position = Vector3(0, 0, 0) setget set_puppet_position
puppet var puppet_velocity = Vector3(0, 0, 0)

puppet var puppet_body_transform = Vector3(0, 0, 0)
puppet var puppet_head_transform = Vector3(0, 0, 0)


func _ready():
	print("ready")

func _physics_process(delta):
	if is_network_master(): # only steer this player's object
	# if !is_network_master():
		velocity = Vector3()
		angular_velocity = 0
		
		# get inputs
		var forward_input = int(Input.is_action_pressed("Forward")) - int(Input.is_action_pressed("Back"))
		var turn_input = int(Input.is_action_pressed("Left")) - int(Input.is_action_pressed("Right"))
		
		if Input.is_action_just_pressed("MainAction"):
			shoot()
		
		# interpret inputs
		velocity.z = forward_input*max_speed
		velocity = move_and_slide(velocity.rotated(Vector3(0, 1, 0), rotation.y))
		angular_velocity = turn_input*max_angular_velocity
		rotate_y(deg2rad(angular_velocity)*delta)
		
		# get mouse position and rotate barrel towards it
		var pointed_position = mousePositionToWorldPosition()
		if pointed_position != null:
			get_node("Model/Head").look_at(flatten(pointed_position), Vector3.UP)
			#DEBUG
			var ball = get_tree().root.get_node("World/DEBUG_BALL")
			if ball == null:
				return
			ball.transform.origin = pointed_position
			
	else: # This is another player - move them according to the data from network
		var body_quat = Quat(transform.basis)
		var pup_body_quat = Quat(puppet_body_transform)
		var body_rotated = body_quat.slerp(pup_body_quat, 0.5)

		var head_quat = Quat($Model/Head.transform.basis)
		var pup_head_quat = Quat(puppet_head_transform)
		var head_rotated = head_quat.slerp(pup_head_quat, 0.5)

		transform.basis = Basis(body_rotated)
		$Model/Head.transform.basis = Basis(head_rotated)

		if not tween.is_active():
			puppet_velocity = move_and_slide(puppet_velocity.rotated(Vector3(0, 1, 0), rotation.y))

func shoot():
	var bullet_transform = get_node("Model/Head/Barrel/BulletOrigin").global_transform
	var new_bullet = bullet_scene.instance()
	owner.add_child(new_bullet)
	new_bullet.transform = bullet_transform

func flatten(vector: Vector3) -> Vector3:
	return Vector3(vector.x, 0, vector.z)

func mousePositionToWorldPosition():
	var space_state = get_world().direct_space_state

	var mouse_pos = get_viewport().get_mouse_position()

	var camera = get_tree().root.get_camera()
	# var ray_origin = camera.project_ray_origin(mouse_pos)
	var ray_origin = camera.global_translation
	# camera.project_local_ray_normal()
	# var ray_direction = camera.project_ray_normal(mouse_pos) * 300
	var ray_direction = camera.project_position(mouse_pos, 300)

	var ray_array = space_state.intersect_ray(ray_origin, ray_direction)

	if ray_array.has("position"):
		return ray_array["position"]
	return null
	
func set_puppet_position(new_value) -> void:
	puppet_position = new_value

	tween.interpolate_property(self, "global_translation", global_translation, puppet_position, 0.1)
	tween.start()

func _on_NetworkTickRate_timeout():
	if is_network_master():
		rset_unreliable("puppet_position", global_translation)
		rset_unreliable("puppet_velocity", velocity)

		rset_unreliable("puppet_body_transform", transform)
		rset_unreliable("puppet_head_transform", $Model/Head.transform)
