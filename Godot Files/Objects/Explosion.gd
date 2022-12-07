extends Spatial

onready var particles: Particles = $Particles
onready var lifetime_timer: Timer = $LifetimeTimer

func _ready():
	particles.emitting = true
	lifetime_timer.start()

func _on_HitBox_body_entered(body:Node):
	if body.has_method("damage"):
		body.damage(20)


func _on_LifetimeTimer_timeout():
	#TODO: rpc("destroy")
	queue_free()
