extends KinematicBody

var velocity:Vector3
var angular_velocity:int

func _ready():
	print("ready")

func _physics_process(delta):
	velocity = Vector3()
	angular_velocity = 0
	
	if Input.is_action_pressed("Forward"):
		#Move forward
		velocity.z += 10

	if Input.is_action_pressed("Back"):
		#Move back
		velocity.z -= 10

	if Input.is_action_pressed("Left"):
		#Turn left
		angular_velocity += 40

	if Input.is_action_pressed("Right"):
		#Turn right
		angular_velocity -= 40

	velocity = move_and_slide(velocity.rotated(Vector3(0, 1, 0), rotation.y))
	# if velocity.x != 0: 
	# 	print("Tank position: " + str(transform.origin))
	# 	print("Model origin: " + str($Model.transform.origin))

	rotate_y(deg2rad(angular_velocity)*delta)
	var pointed_position = mousePositionToWorldPosition()
	if pointed_position != null:
		get_node("Model/Head").look_at(flatten(pointed_position), Vector3.UP)
		var ball = get_tree().root.get_node("World/DEBUG_BALL")
		if ball == null:
			return
		ball.transform.origin = pointed_position
		
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
	
