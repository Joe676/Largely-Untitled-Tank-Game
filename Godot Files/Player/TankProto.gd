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
		velocity = 10 * Vector3.FORWARD

	if Input.is_action_pressed("Back"):
		#Move back
		velocity.z -= 10

	if Input.is_action_pressed("Left"):
		#Turn left
		angular_velocity += 20

	if Input.is_action_pressed("Right"):
		#Turn right
		angular_velocity -= 20

	velocity = move_and_slide(velocity)
	if velocity.x != 0: 
		print("Tank position: " + str(transform.origin))
		print("Model origin: " + str($Model.transform.origin))

	rotate_y(deg2rad(angular_velocity)*delta)
