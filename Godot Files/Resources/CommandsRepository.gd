extends Node

var explosion_scene = preload("res://Objects/Explosion.tscn") 

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
	if not hit_body.has_method("is_player"):
		return
	var shooter = __get_shooter_from_bullet(bullet)
	shooter.finalize_reload()

onready var reload_on_hit_command = _base_command.new(funcref(self, "_reload_on_hit"))


func is_unoccluded(ray_origin_object, ray_target_object):
	var level_node = get_tree().root.get_node("World")
	var space_state = level_node.get_world().direct_space_state
	var result = space_state.intersect_ray(ray_origin_object.global_translation, ray_target_object.global_translation, [ray_origin_object])
	if result and result.collider.name == ray_target_object.name:
		print("ray collided with: ", result.collider.name)
		return true
	return false
		

func __get_closest_player(point: Vector3, bullet):
	var closest_player = null
	var min_distance_squared = pow(2, 63)-1 #INT_MAX
	for player in Global.get_all_players():
		if not is_unoccluded(bullet, player):
			print("is occluded")
			continue
		var cur_dist_sq = point.distance_squared_to(player.global_translation) 
		if  cur_dist_sq < min_distance_squared:
			min_distance_squared = cur_dist_sq
			closest_player = player
	if closest_player != null:
		print("Closest player: ", closest_player.player_name)
	return closest_player


func _rotate_towards_closest_player(bullet:KinematicBody, _hit_body, hit_point):
	print("directed")
	print("bullet bounced from: ", _hit_body.name)
	var closest_player = __get_closest_player(hit_point, bullet)
	if closest_player != null:
		var closest_point = closest_player.global_translation
		bullet.look_at(closest_point, Vector3.UP)
		bullet.velocity = -bullet.transform.basis.z * bullet.speed
		bullet.velocity = Global.strip_y_rotation(bullet.velocity).normalized() * bullet.speed

onready var rotate_bullet_to_closest_player_command = _postponed_command.new(funcref(self, "_rotate_towards_closest_player"))

func _knock_player_back(bullet, hit_body, _hit_point):
	if not hit_body.has_method("is_player"):
		return
	print("bullet velocity: ", bullet.velocity)
	print("bullet basis: ", bullet.global_transform.basis.z)
	print("bullet local basis: ", bullet.transform.basis.z)
	print("hit body y rotation: ", hit_body.rotation.y)

	var direction:Vector3 = bullet.global_transform.basis.z#.normalized()
	direction = direction.rotated(Vector3.UP, hit_body.rotation.y)
	var speed = 20
	hit_body.knockback_velocity += direction*speed

onready var knockback_command = _base_command.new(funcref(self, "_knock_player_back"))

func _explosion(_bullet, _hit_body, hit_point):
	var explosion_instance = explosion_scene.instance()
	explosion_instance.global_translation = hit_point
	PersistentNodes.add_child(explosion_instance)
	pass

onready var explosion_command = _base_command.new(funcref(self, "_explosion"))
