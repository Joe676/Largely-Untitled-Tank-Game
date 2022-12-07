extends KinematicBody

export(int) var damage: int = 40
export(int) var speed: int = 20
export(float) var lifespan: float = 1.0
export(float) var size: float = 0.5
export(int) var bounces_left: int

var owner_id: int
var shooting_point_transform: Transform

var on_hit: Array = []

var velocity = Vector3.ZERO

puppet var puppet_position: Vector3 setget set_puppet_position
puppet var puppet_velocity: Vector3
puppet var puppet_transform: Transform

func ctor(_damage: int, _speed: int, _lifespan: float, _size: float, bounces: int, _on_hit: Array, _owner_id: int, _transform: Transform):
	damage = _damage
	speed = _speed
	lifespan = _lifespan
	size = _size
	bounces_left = bounces
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
	if not is_network_master():
		global_translation = puppet_position

func _physics_process(delta):
	var collision: KinematicCollision = null
	if(is_network_master()):
		collision = move_and_collide(velocity * delta)
	else:
		collision = move_and_collide(puppet_velocity * delta)
	if collision:
		_on_collision(collision)

sync func destroy() -> void:
	queue_free()

func _on_LifespanTimer_timeout():
	if is_network_master():
		rpc("destroy")

func _on_collision(collision:KinematicCollision):
	var body = collision.collider
	var damaged: bool = false
	var postponed = []
	# print(bounces_left)
	for command in on_hit:
		# print(command)
		if command.get("postponed"):
			postponed.append(command)
		else:
			command.execute_command(self, body, collision.position)
	if body.has_method("damage"):
		body.damage(damage)
		damaged = true
	if (damaged or bounces_left == 0) and is_network_master():
		rpc("destroy")
		return
	if bounces_left > 0:
		print("bouncing")
		bounces_left -= 1
		bounce(collision)
	for command in postponed:
		command.execute_command(self, body, collision.position)

func bounce(collision: KinematicCollision):
	var collision_normal = collision.normal
	# print("normal ", collision_normal)
	# print("old velocity ", velocity)
	velocity = velocity.reflect(collision_normal) * -1
	# print("new velocity ", velocity)
	look_at(global_translation + velocity*500, Vector3.UP)
