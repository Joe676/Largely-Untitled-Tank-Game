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
		{},
		[]#TODO: Bounces as bullet's attribute
		)

onready var full_auto_card: BaseCard = base_card.new("FULL AUTO",
		"You may shoot as fast as possible, but your bullets deal less damage.",
		{"shooting_cooldown_time": ["*", 0.2],
		"max_bullets": ["+", 10],
		"reload_time": ["+", 0.5],
		"bullet_damage": ["*", 0.6]},
		[]
		)

onready var garanade_card: BaseCard = base_card.new("Granade Launcher",
		"You launch granades instead of bullets.",
		{},
		[]#TODO
		)

onready var flame_card: BaseCard = base_card.new("Flaming bullets",
		"Your bullets set the opponents ablaze!",
		{},
		[]#TODO: player's active state (same for freezing)
		)
		
onready var life_steal_card: BaseCard = base_card.new("Life Steal", 
		"When you hit an enemy with a bullet you get healed by half of the amount of damage caused.", 
		{}, 
		[CommandsRepository.steal_health_command])

onready var nuke_card: BaseCard = base_card.new("NUKE",
		"Your bullets hit like nukes",
		{},
		[]#TODO
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
		{},
		[]#TODO
		)
	
onready var freezing_bullet_card: BaseCard = base_card.new("Freezing Bullet",
		"Your bullets freeze hit opponents.",
		{},
		[]#TODO
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
		{},
		[]
		)

onready var knockback_card: BaseCard = base_card.new("Knockback",
		"Your bullets knock enemies back on hit.",
		{},
		[]#TODO
		)

onready var directed_bounce_card: BaseCard = base_card.new("Directed Bounce",
		"The bullets you shoot bounce towards the closest player. Be careful, that might be you.",
		{},
		[]#TODO
		)

onready var tactical_advantage_card: BaseCard = base_card.new("Tactical Advantage",
		"Hitting an opponent reloads your weapon.",
		{},
		[]
		)

onready var cards: Array = [
	tough_card,
	speedy_card,
	glass_cannon,
	cockroach_card,
	sniper_card,
	full_auto_card,
	life_steal_card,
	quick_reload_card,
	big_boy_card,
	cowboy_card
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