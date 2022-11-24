extends Node

var _base_command = preload("res://Resources/BaseCommand.gd")

func _steal_health(bullet, hit_body, _hit_point):
	var shooter_id: int = bullet.owner_id
	if str(shooter_id) == hit_body.name:
		return
	var shooter = get_node("/root/PersistentNodes/%d" % shooter_id)
	var healing_value = min(bullet.damage, hit_body.current_health)
	shooter.update_health(healing_value)

onready var steal_health_command = _base_command.new(funcref(self, "_steal_health")) 


