extends Node

var _base_command = preload("res://Resources/BaseCommand.gd")
var _postponed_command = preload("res://Resources/PostponedCommand.gd")

func __get_shooter_from_bullet(bullet):
	var shooter_id: int = bullet.owner_id
	return get_node("/root/PersistentNodes/%d" % shooter_id)

func _steal_health(bullet, hit_body, _hit_point):
	var shooter_id: int = bullet.owner_id
	if str(shooter_id) == hit_body.name or not hit_body.get("current_health"):
		return
	var shooter = get_node("/root/PersistentNodes/%d" % shooter_id)
	var healing_value = 0.5 * min(bullet.damage, hit_body.current_health)
	shooter.update_health(healing_value)

onready var steal_health_command = _base_command.new(funcref(self, "_steal_health")) 

func _reload_on_hit(bullet, hit_body, _hit_point):
	if not hit_body.has_method["is_player"]:
		return
	var shooter = __get_shooter_from_bullet(bullet)
	shooter.finalize_reload()

onready var reload_on_hit_command = _base_command.new(funcref(self, "_reload_on_hit"))

func __get_closest_player(point: Vector3):
	var closest_player = null
	var min_distance_squared = pow(2, 63)-1 #INT_MAX
	for player in Global.get_all_players():
		var cur_dist_sq = point.distance_squared_to(player.global_translation) 
		if  cur_dist_sq < min_distance_squared:
			min_distance_squared = cur_dist_sq
			closest_player = player
	return closest_player


func _rotate_towards_closest_player(bullet, _hit_body, hit_point):
	#TODO
	pass