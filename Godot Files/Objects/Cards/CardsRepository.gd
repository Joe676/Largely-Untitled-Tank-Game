extends Node

var base_card = preload("res://Objects/Cards/BaseCard.gd")


onready var tough_card: BaseCard = base_card.new("Tough", 
		"You get a lot of life, but your speed is halved.", 
		{"max_health": ["*", 2], 
		"max_speed": ["*", 0.6]}, 
		[])

onready var speedy_card: BaseCard = base_card.new("Speedy Gonzalez",
		"You are quite speedy, though you have less health.",
		{"max_speed": ["*", 2],
		"max_angular_speed": ["*", 1.5],
		"max_health": ["*", 0.75]},
		[]
		)
	
onready var glass_cannon: BaseCard = base_card.new("Glass Cannon",
		"You deal a lot of damage, but are easily hurt.",
		{"max_health": ["*", 0.25],
		"bullet_damage": ["+", 100]},
		[]
		)

onready var cockroach_card: BaseCard = base_card.new("Cockroach",
		"You are like a cockroach - small, but hard to kill.",
		{"max_health": ["*", 0.4],
		"healing_value": ["+", 5],
		"time_to_healing": ["*", 0.5],
		"time_between_healing": ["*", 0.8]},
		[]
		)

onready var sniper_card: BaseCard = base_card.new("Sniper",
		"You are now shooting a sniper rifle.",
		{"bullet_damage": ["+", 50],
		"bullet_speed": ["*", 5],
		"shooting_cooldown_time": ["+", 0.5],
		"max_bullets": ["+", -2]},
		[]
		)

onready var rubber_bullets_card: BaseCard = base_card.new("Rubber Bullets",
		"Your bullets bounce twice before being destroyed",
		{"bullet_bounces": ["+", 2]},
		[]
		)

onready var full_auto_card: BaseCard = base_card.new("FULL AUTO",
		"You may shoot as fast as possible, but your bullets deal less damage.",
		{"shooting_cooldown_time": ["*", 0.2],
		"max_bullets": ["+", 10],
		"reload_time": ["+", 0.5],
		"bullet_damage": ["*", 0.6]},
		[]
		)

onready var granade_card: BaseCard = base_card.new("Granade Launcher",
		"You launch granades instead of bullets.",
		{"bullet_damage": ["*", 0.8],
		"bullet_size": ["*", 1.2]},
		[CommandsRepository.explosion_command]
		)

onready var flame_card: BaseCard = base_card.new("Flaming bullets",
		"Your bullets set the opponents ablaze!",
		{"bullet_speed": ["+", 10]},
		[CommandsRepository.fire_command]
		)
		
onready var life_steal_card: BaseCard = base_card.new("Life Steal", 
		"When you hit an enemy with a bullet you get healed by half of the amount of damage caused.", 
		{"time_between_healing": ["*", 2]}, 
		[CommandsRepository.steal_health_command])

onready var nuke_card: BaseCard = base_card.new("NUKE",
		"Your bullets hit like nukes",
		{"max_bullets": ["+", -2],
		"bullet_damage": ["+", 100],
		"reload_time": ["+", 1],
		"shooting_cooldown_time": ["+", 0.2],
		"bullet_size": ["*", 2]},
		[CommandsRepository.explosion_command]
		)

onready var quick_reload_card: BaseCard = base_card.new("Quick Reload",
		"You reload much quicker.",
		{"reload_time": ["+", -0.5]},
		[]
		)

onready var big_boy_card: BaseCard = base_card.new("Big Boy",
		"You are big now, though you heal much slower.",
		{"max_health": ["+", 100],
		"time_to_healing": ["+", 5],
		"time_between_healing": ["+", 1],
		"healing_value": ["*", 0.5]},
		[]
		)

onready var fragmentation_card: BaseCard = base_card.new("Fragmentation",
		"Your bullet splits into many smaller fragments that scatter on hit",
		{"reload_time": ["+", 0.2]},
		[CommandsRepository.fragmentation_command]
		)
	
onready var freezing_bullet_card: BaseCard = base_card.new("Freezing Bullet",
		"Your bullets freeze hit opponents.",
		{"reload_time": ["+", 0.2]},
		[CommandsRepository.freeze_command]
		)

onready var cowboy_card: BaseCard = base_card.new("Cowboy",
		"You can shoot really quickly now, but reloading takes significant time.",
		{"shooting_cooldown_time": ["*", 0.05],
		"bullet_damage": ["+", 20],
		"reload_time": ["+", 1]},
		[]
		)

onready var chaos_card: BaseCard = base_card.new("CHAOS",
		"The bullets you shoot bounce a lot.",
		{"bullet_bounces": ["+", 5],
		"bullet_lifetime": ["+", 2]},
		[]
		)

onready var knockback_card: BaseCard = base_card.new("Knockback",
		"Your bullets knock enemies back on hit.",
		{},
		[CommandsRepository.knockback_command]#TODO: reconsider - many problems
		)

onready var directed_bounce_card: BaseCard = base_card.new("Directed Bounce",
		"The bullets you shoot bounce towards the closest player. Be careful, that might be you.",
		{"bullet_bounces": ["+", 1]},
		[CommandsRepository.rotate_bullet_to_closest_player_command]
		)

onready var tactical_advantage_card: BaseCard = base_card.new("Tactical Advantage",
		"Hitting an opponent reloads your weapon.",
		{"reload_time": ["+", 0.5]},
		[CommandsRepository.reload_on_hit_command]
		)

onready var cards: Array = [
	tough_card,
	speedy_card,
	glass_cannon,
	cockroach_card,
	sniper_card,
	rubber_bullets_card,
	full_auto_card,
	granade_card,
	flame_card,
	life_steal_card,
	nuke_card,
	quick_reload_card,
	big_boy_card,
	fragmentation_card,
	freezing_bullet_card,
	cowboy_card,
	chaos_card,
	# knockback_card, #consider throwing this one away
	# directed_bounce_card, #consider throwing this away - seems to not work properly
	tactical_advantage_card
]

func get_random_card() -> BaseCard:
	randomize()
	return cards[randi() % cards.size()]

func get_3random_cards():
	var cards_size = cards.size()
	var idx1 = randi() % cards_size

	var idx2 = randi() % cards_size
	while idx2 == idx1:
		idx2 = randi() % cards_size
	
	var idx3 = randi() % cards_size
	while idx3 == idx1 or idx3 == idx2:
		idx3 = randi() % cards_size

	return [cards[idx1], cards[idx2], cards[idx3]]