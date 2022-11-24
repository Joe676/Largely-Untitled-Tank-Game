extends Area

export(int) var damage: int = 40
export(int) var speed: int = 20
export(float) var lifespan: float = 1.0
export(float) var size: float = 0.5

var owner_id: int
var shooting_point_transform: Transform

var on_hit: Array = []

var velocity = Vector3.ZERO

puppet var puppet_position: Vector3 setget set_puppet_position
puppet var puppet_velocity: Vector3
puppet var puppet_transform: Transform

func ctor(_damage: int, _speed: int, _lifespan: float, _size: float, _on_hit: Array, _owner_id: int, _transform: Transform):
	damage = _damage
	speed = _speed
	lifespan = _lifespan
	size = _size
	on_hit = _on_hit
	owner_id = _owner_id
	shooting_point_transform = _transform

	return self

func _ready():
	visible = false
	yield(get_tree(), "idle_frame")
	if(is_network_master()):
		transform = shooting_point_transform
		var mesh = $Mesh
		mesh.transform = mesh.transform.scaled(Vector3(size, size, size))
		var lifespan_timer = $LifespanTimer
		lifespan_timer.wait_time = lifespan
		lifespan_timer.start()

		velocity = transform.basis.z * speed

		rset("puppet_velocity", velocity)
		rset("puppet_position", global_translation)
		rset("puppet_transform", global_transform)
	visible = true

func set_puppet_position(new_value) -> void:
	puppet_position = new_value
	global_translation = puppet_position

func _physics_process(delta):
	if(is_network_master()):
		transform.origin += velocity * speed * delta
	else:
		# print("puppet velocity", puppet_velocity)
		transform.origin += puppet_velocity * speed * delta

sync func destroy() -> void:
	# print("rpc destroying the bullet")
	queue_free()

func _on_LifespanTimer_timeout():
	if is_network_master():
		rpc("destroy")

func _on_Bullet_body_entered(body:Node):
	# for command in on_hit:
	# 	command.execute_command(self, body, null)
	# 	print("command executed")
	if body.has_method("damage"):
		print("player ", body.name, " hit!")
		body.damage(damage)
	if is_network_master():
		rpc("destroy")
