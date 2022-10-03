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
	if velocity.x != 0: 
		print("Tank position: " + str(transform.origin))
		print("Model origin: " + str($Model.transform.origin))

	rotate_y(deg2rad(angular_velocity)*delta)
