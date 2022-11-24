extends Node

var base_card = preload("res://Objects/Cards/BaseCard.gd")


var tank_card: BaseCard = base_card.new("TANK", 
		"", 
		{"max_health": +50, 
		"max_speed": -2}, 
		[])

var huge_magazine_card: BaseCard = base_card.new("Huge Magazine", 
		"Your magazine is HUGE.", 
		{"max_bullets": +50}, 
		[])

var life_steal_card: BaseCard = base_card.new("Life Steal", 
		"When you hit an enemy with a bullet you get healed by the amiunt of damage caused.", 
		{"max_health": +200}, 
		[CommandsRepository.steal_health_command])

var cards: Array = [
	tank_card,
	huge_magazine_card,
	life_steal_card
]

func get_random_card() -> BaseCard:
	randomize()
	return cards[randi() % cards.size()]
