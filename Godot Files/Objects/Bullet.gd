extends Area

export(int) var damage: int = 40
export(int) var speed: int = 20
export(float) var lifespan: float = 1.0
export(float) var size: float = 0.5

var on_hit: Array = []

var velocity = Vector3.ZERO

func ctor(_damage: int, _speed: int, _lifespan: float, _size: float, _on_hit: Array):
	damage = _damage
	speed = _speed
	lifespan = _lifespan
	size = _size
	on_hit = _on_hit

	return self

func _ready():
	var mesh = $Mesh
	mesh.transform = mesh.transform.scaled(Vector3(size, size, size))
	var lifespan_timer = $LifespanTimer
	lifespan_timer.wait_time = lifespan
	lifespan_timer.start()

func _physics_process(delta):
	velocity = transform.basis.z * speed
	transform.origin += velocity * delta

func _on_LifespanTimer_timeout():
	queue_free()

func _on_Bullet_body_entered(_body:Node):
	queue_free()
