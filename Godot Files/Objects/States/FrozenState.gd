extends Node

onready var duration_timer = $DurationTimer

export var slowdown_factor = 4
var initial_speed
var target

func start_freeze():
	if is_network_master():
		rpc("remote_start_freeze")

sync func remote_start_freeze():
	initial_speed = target.max_speed
	target.current_speed /= slowdown_factor
	duration_timer.start()

sync func destroy() -> void:
	queue_free()

func _on_DurationTimer_timeout():
	target.current_speed = initial_speed
	if is_network_master():
		rpc("destroy")
