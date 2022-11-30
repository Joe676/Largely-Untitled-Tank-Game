extends KinematicBody

signal health_updated(id, new_value, max_health)#, player_id)
signal bullets_updated(current_bullets, max_bullets)
signal died(id)

onready var tween = $Tween
onready var own_info_hud = $HUD/OwnInfo
onready var reloading_lbl = $HUD/OwnInfo/VFlowContainer/ReloadingLabel

onready var shooting_timer: Timer = $Timers/ShootingTimer
onready var reload_timer: Timer = $Timers/ReloadTimer
onready var pre_heal_timer: Timer = $Timers/PreHealTimer
onready var heal_timer: Timer = $Timers/HealTimer

export (PackedScene) var bullet_scene = load("res://Objects/Bullet.tscn")

var player_name: String setget set_player_name
puppet var puppet_player_name: String setget set_puppet_player_name

var player_colour: Color setget set_player_colour
puppet var puppet_player_colour: Color setget set_puppet_player_colour

var current_vp: int

#attributes
#movement
export(int) var max_speed: int = 10 
export(int) var max_angular_speed: int = 40
export(int) var max_health: int = 100
#healing
export(float) var time_to_healing: float = 5.0
export(float) var time_between_healing: float = 1.0
export(int, 0, 100) var healing_value: int = 5
#shooting
export(int) var max_bullets: int = 6
export(float) var reload_time: float = 1.5
export(float) var shooting_cooldown_time: float = 0.4
#bullet characteristics
export(int) var bullet_damage: int = 40
export(int) var bullet_speed: int = 5
export(float) var bullet_lifetime: float = 2.0
export(float) var bullet_size: float = 1.0 #scale
var bullet_on_hit: Array = []

var cards: Array = []

var velocity: Vector3
var angular_velocity: int

var current_health: int setget set_current_health
puppet var puppet_current_health: int setget set_puppet_current_health

var current_bullets: int

var is_dead: bool = false

var is_reloading: bool = false
var has_just_shot: bool = false
var can_shoot: bool = true

puppet var puppet_position = Vector3(0, 0, 0) setget set_puppet_position
puppet var puppet_velocity = Vector3(0, 0, 0)

puppet var puppet_body_rotation = 0
puppet var puppet_head_rotation = 0

func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	GameState.connect("start_game", self, "_start_game")
	GameState.connect("start_round", self, "start_round")
	GameState.connect("selected_card", self, "attach_card")
	start_round()

func set_up():
	if is_network_master():
		connect("health_updated", own_info_hud, "_on_health_updated")
		emit_signal("health_updated", get_tree().get_network_unique_id(), current_health, max_health)

		connect("bullets_updated", own_info_hud, "_on_bullets_updated")
		emit_signal("bullets_updated", current_bullets, max_bullets)
		
		# print("health and bullets signals connected")
	else:
		$HUD.visible = false

func set_timers():
	shooting_timer.stop()
	reload_timer.stop()
	pre_heal_timer.stop()
	heal_timer.stop()
	shooting_timer.wait_time = shooting_cooldown_time
	reload_timer.wait_time = reload_time
	pre_heal_timer.wait_time = time_to_healing
	heal_timer.wait_time = time_between_healing

func _start_game():
	$HUD.set_up_info()

func start_round():
	is_dead = false
	can_shoot = true
	visible = true
	set_current_health(max_health)
	$CollisionShape.disabled = false
	set_timers()
	current_bullets = max_bullets
	emit_signal("bullets_updated", current_bullets, max_bullets)

func _physics_process(delta):
	if not can_move():
		return
	if is_network_master() : # only steer this player's object
		velocity = Vector3()
		angular_velocity = 0
		
		# get inputs
		var forward_input = int(Input.is_action_pressed("Forward")) - int(Input.is_action_pressed("Back"))
		var turn_input = int(Input.is_action_pressed("Left")) - int(Input.is_action_pressed("Right"))
		
		if Input.is_action_just_pressed("MainAction") and can_shoot:
			if not has_just_shot and not is_reloading:
				shoot()
		
		# interpret inputs
		velocity.z = forward_input*max_speed
		velocity = move_and_slide(velocity.rotated(Vector3(0, 1, 0), rotation.y))
		angular_velocity = turn_input*max_angular_speed
		rotate_y(deg2rad(angular_velocity)*delta)
		
		# get mouse position and rotate barrel towards it
		var pointed_position = mousePositionToWorldPosition()
		if pointed_position != null:
			get_node("Model/Head").look_at(flatten(pointed_position), Vector3.UP)
			#DEBUG
			var ball = get_tree().root.get_node("World/DEBUG_BALL")
			if ball == null:
				return
			ball.transform.origin = pointed_position
			
	else: # This is another player - move them according to the data from network
		rotation.y = puppet_body_rotation
		$Model/Head.rotation.y = puppet_head_rotation

		if not tween.is_active(): # Client predictions
			puppet_velocity = move_and_slide(puppet_velocity.rotated(Vector3(0, 1, 0), rotation.y))

func shoot():
	rpc("instance_bullet", get_tree().get_network_unique_id())
	has_just_shot = true
	shooting_timer.start()
	current_bullets -= 1
	emit_signal("bullets_updated", current_bullets, max_bullets)
	if current_bullets == 0:
		start_reload()

func start_reload():
	is_reloading = true
	reload_timer.start()
	reloading_lbl.visible = true

func flatten(vector: Vector3) -> Vector3:
	return Vector3(vector.x, 0, vector.z)

func mousePositionToWorldPosition():
	var space_state = get_world().direct_space_state

	var mouse_pos = get_viewport().get_mouse_position()

	var camera = get_tree().root.get_camera()
	if camera == null:
		return null

	var ray_origin = camera.global_translation
	var ray_direction = camera.project_position(mouse_pos, 300)

	var ray_array = space_state.intersect_ray(ray_origin, ray_direction)

	if ray_array.has("position"):
		return ray_array["position"]
	return null
	
func set_puppet_position(new_value) -> void:
	puppet_position = new_value

	tween.interpolate_property(self, "global_translation", global_translation, puppet_position, 0.1) # Interpolate position to compensate for lag
	tween.start()

func _on_NetworkTickRate_timeout():
	if is_network_master():
		rset_unreliable("puppet_position", global_translation)
		rset_unreliable("puppet_velocity", velocity)

		rset_unreliable("puppet_body_rotation", rotation.y)
		rset_unreliable("puppet_head_rotation", $Model/Head.rotation.y)

sync func instance_bullet(id):
	var bullet_transform: Transform = get_node("Model/Head/Barrel/BulletOrigin").global_transform
	var new_bullet = Global.instance_node_with_transform(bullet_scene, bullet_transform)\
		.ctor(bullet_damage, bullet_speed, bullet_lifetime, bullet_size, bullet_on_hit, id, bullet_transform)
	
	Global.name_networked_object(new_bullet, name, "Bullet")
	new_bullet.set_network_master(id)

	get_parent().add_child(new_bullet)
	pass

sync func die():
	is_dead = true
	can_shoot = false
	hide()
	$CollisionShape.disabled = true
	emit_signal("died", name)

func set_current_health(new_value):
	# print("health changing: ", new_value)
	current_health = new_value
	if new_value <= 0:
		current_health = 0
	elif new_value >= max_health:
		current_health = max_health
	emit_signal("health_updated", get_network_master(), current_health, max_health)#, name)
	if is_network_master():
		rset("puppet_current_health", current_health)
		if current_health == 0:
			rpc("die")

func set_puppet_current_health(new_value):
	puppet_current_health = new_value
	if not is_network_master():
		current_health = puppet_current_health
		emit_signal("health_updated", get_network_master(), current_health, max_health)

func damage(amount):
	heal_timer.stop()
	heal_timer.paused = true
	pre_heal_timer.start()
	if get_tree().is_network_server():
		rpc("update_health", -amount)
		
sync func update_health(amount):
	set_current_health(current_health + amount)

func _on_ShootingTimer_timeout():
	has_just_shot = false

func _on_PreHealTimer_timeout():
	heal_timer.paused = false
	heal_timer.start()

func _on_HealTimer_timeout():
	if not is_dead:
		update_health(healing_value)

func _on_ReloadTimer_timeout():
	is_reloading = false
	current_bullets = max_bullets
	emit_signal("bullets_updated", current_bullets, max_bullets)
	reloading_lbl.visible = false

func set_player_name(new_name: String):
	player_name = new_name
	if is_network_master():
		rset("puppet_player_name", player_name)
	# print("name ", player_name, " set for player ", name)

func set_player_colour(new_colour: Color):
	player_colour = new_colour
	# var material = $Model/Body/Body.get_surface_material(0)
	var material = SpatialMaterial.new()
	material.albedo_color = player_colour
	$Model/Body/Body.set_surface_material(0, material)
	if is_network_master():
		rset("puppet_player_colour", player_colour)
	# print("colour set for player ", name)

func set_puppet_player_colour(new_colour: Color):
	puppet_player_colour = new_colour
	if not is_network_master():
		set_player_colour(puppet_player_colour)

func set_puppet_player_name(new_name: String):
	puppet_player_name = new_name
	if not is_network_master():
		player_name = puppet_player_name
	
func _player_connected(id):
	rset_id(id, "puppet_player_name", player_name)
	rset_id(id, "puppet_player_colour", player_colour)

func can_move():
	return GameState.state == GameState.State.IN_GAME

func is_player():
	pass # This is a dummy function to confirm type

func move_to_spawn_point(spawn_point: Transform):
	if not is_network_master():
		rpc("remote_move_to_spawn_point", spawn_point)
	else:
		global_transform = spawn_point

master func remote_move_to_spawn_point(spawn_point: Transform):
	global_transform = spawn_point

func attach_card(card: BaseCard):
	card.attach_to_player(self)