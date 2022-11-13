extends Area

export (int) var speed : int = 20
export (float) var life_limit : float = 1

var velocity = Vector3.ZERO

func _ready():
	var lifespan_timer = $LifespanTimer
	lifespan_timer.wait_time = life_limit
	lifespan_timer.start()

func _physics_process(delta):
	velocity = transform.basis.z * speed
	transform.origin += velocity * delta


func _on_LifespanTimer_timeout():
	queue_free()

func _on_Bullet_body_entered(body:Node):
	# print("hit: " + str(body.name))
	queue_free()
