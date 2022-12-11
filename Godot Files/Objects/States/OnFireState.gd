extends Node

onready var duration_timer = $DurationTimer
onready var between_timer = $BetweenTimer

var target
export var damage = 2

func start_fire():
	if is_network_master():
		rpc("remote_start_fire")

sync func remote_start_fire():
	duration_timer.start()
	between_timer.start()

sync func destroy() -> void:
	queue_free()

func _on_DurationTimer_timeout():
	if is_network_master():
		rpc("destroy")

sync func deal_damage():
	print("Fire is dealing damage")
	if target.has_method("damage"):
		target.damage(damage)

func _on_BetweenTimer_timeout():
	if is_network_master():
		rpc("deal_damage")