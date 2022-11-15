extends KinematicBody

onready var tween = $Tween

export (PackedScene) var bullet_scene = load("res://Objects/Bullet.tscn")

#atributes
#movement
export(int) var max_speed: int = 10 
export(int) var max_angular_speed: int = 40
export(int) var max_health: int = 100
#healing
export(float) var time_to_healing: float = 5.0
export(float) var time_between_healing: float = 1.0
export(int, 0, 100) var healing_value: int = 5
#shooting
export(int) var max_bullets: int = 6
export(float) var reload_time: float = 1.5
export(float) var shooting_cooldown_time: float = 0.4
#bullet characteristics
export(int) var bullet_damage: int = 40
export(int) var bullet_speed: int = 20
export(float) var bullet_lifetime: float = 2.0
export(float) var bullet_size: float = 1.0 #scale
var bullet_on_hit: Array = []


var velocity: Vector3
var angular_velocity: int

puppet var puppet_position = Vector3(0, 0, 0) setget set_puppet_position
puppet var puppet_velocity = Vector3(0, 0, 0)

puppet var puppet_body_rotation = 0
puppet var puppet_head_rotation = 0

func _ready():
	print("ready")

func _physics_process(delta):
	if is_network_master(): # only steer this player's object
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
		angular_velocity = turn_input*max_angular_speed
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
		rotation.y = puppet_body_rotation
		$Model/Head.rotation.y = puppet_head_rotation

		if not tween.is_active(): # Client predictions
			puppet_velocity = move_and_slide(puppet_velocity.rotated(Vector3(0, 1, 0), rotation.y))

func shoot():
	var bullet_transform: Transform = get_node("Model/Head/Barrel/BulletOrigin").global_transform
	var new_bullet = bullet_scene.instance().ctor(bullet_damage, bullet_speed, bullet_lifetime, bullet_size, bullet_on_hit)
	get_parent().add_child(new_bullet)
	new_bullet.transform = bullet_transform

func flatten(vector: Vector3) -> Vector3:
	return Vector3(vector.x, 0, vector.z)

func mousePositionToWorldPosition():
	var space_state = get_world().direct_space_state

	var mouse_pos = get_viewport().get_mouse_position()

	var camera = get_tree().root.get_camera()
	if camera == null:
		return null

	var ray_origin = camera.global_translation
	var ray_direction = camera.project_position(mouse_pos, 300)

	var ray_array = space_state.intersect_ray(ray_origin, ray_direction)

	if ray_array.has("position"):
		return ray_array["position"]
	return null
	
func set_puppet_position(new_value) -> void:
	puppet_position = new_value

	tween.interpolate_property(self, "global_translation", global_translation, puppet_position, 0.1) # Interpolate position to compensate for lag
	tween.start()

func _on_NetworkTickRate_timeout():
	if is_network_master():
		rset_unreliable("puppet_position", global_translation)
		rset_unreliable("puppet_velocity", velocity)

		rset_unreliable("puppet_body_rotation", rotation.y)
		rset_unreliable("puppet_head_rotation", $Model/Head.rotation.y)
