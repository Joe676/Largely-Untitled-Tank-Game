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

sync func _instance_explosion(point, id):
	var explosion_instance = explosion_scene.instance()
	explosion_instance.global_translation = point
	Global.name_networked_object(explosion_instance, str(id), "Explosion")
	explosion_instance.set_network_master(id)
	PersistentNodes.add_child(explosion_instance)

func _explosion(_bullet, _hit_body, hit_point):
	rpc("_instance_explosion", hit_point, get_tree().get_network_unique_id())

onready var explosion_command = _base_command.new(funcref(self, "_explosion"))

var bullet_scene = preload("res://Objects/Bullet.tscn")

sync func _instance_fragment(bullet_attrs, rotation):
	print("instancing a fragment")
	var owner_id = bullet_attrs[5]
	var bullet_transform = bullet_attrs[6]
	var new_bullet = Global.instance_node_with_transform(bullet_scene, bullet_transform)\
		.ctor(bullet_attrs[0], bullet_attrs[1], bullet_attrs[2], bullet_attrs[3] * 0.6, bullet_attrs[4] + 1, [], owner_id, bullet_attrs[6])
	new_bullet.rotate_y(rotation)
	
	Global.name_networked_object(new_bullet, name, "Bullet")
	new_bullet.set_network_master(owner_id)
	PersistentNodes.add_child(new_bullet)


func _fragmentation(bullet, hit_body, _hit_point):
	if hit_body.has_method("is_player"):
		return
	for random_rotation in [-PI/4, PI/4]:
		rpc("_instance_fragment", 
				[bullet.damage, bullet.speed, bullet.lifetime, bullet.size, bullet.bounces_left, bullet.owner_id, bullet.global_transform], 
				random_rotation)

onready var fragmentation_command = _base_command.new(funcref(self, "_fragmentation"))

var fire_scene = preload("res://Objects/States/OnFireState.tscn")

sync func _instance_fire(player_id):
	var fire_instance = fire_scene.instance()
		
	var target = PersistentNodes.get_node(str(player_id))
	target.get_node("States").add_child(fire_instance)
	Global.name_networked_object(fire_instance, name, "FireState")
	fire_instance.target = target
	fire_instance.set_network_master(int(player_id))
	fire_instance.start_fire()


func _fire(_bullet, hit_body, _hit_point):
	if hit_body.has_method("is_player"):
		rpc("_instance_fire", hit_body.name)

onready var fire_command = _base_command.new(funcref(self, "_fire"))

var freeze_scene = preload("res://Objects/States/FrozenState.tscn")

sync func _instance_freeze(player_id):
	var freeze_instance = freeze_scene.instance()
	
	var target = PersistentNodes.get_node(str(player_id))
	target.get_node("States").add_child(freeze_instance)
	Global.name_networked_object(freeze_instance, name, "FrozenState")
	freeze_instance.target = target
	freeze_instance.set_network_master(int(player_id))
	freeze_instance.start_freeze()


func _freeze(_bullet, hit_body, _hit_point):
	if hit_body.has_method("is_player"):
		rpc("_instance_freeze", hit_body.name)

onready var freeze_command = _base_command.new(funcref(self, "_freeze"))
