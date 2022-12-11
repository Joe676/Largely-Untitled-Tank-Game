extends Spatial

onready var particles: Particles = $Particles
onready var lifetime_timer: Timer = $LifetimeTimer

func _ready():
	particles.emitting = true
	lifetime_timer.start()

func _on_HitBox_body_entered(body:Node):
	if get_tree().is_network_server() and body.has_method("damage"):
		body.damage(20)

sync func destroy() -> void:
	queue_free()

func _on_LifetimeTimer_timeout():
	if is_network_master():
		rpc("destroy")
