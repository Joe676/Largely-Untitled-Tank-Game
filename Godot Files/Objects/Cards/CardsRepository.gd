extends Node

var base_card = preload("res://Objects/Cards/BaseCard.gd")


onready var tank_card: BaseCard = base_card.new("TANK", 
		"You get a lot ", 
		{"max_health": +50, 
		"max_speed": -2}, 
		[])

onready var huge_magazine_card: BaseCard = base_card.new("Huge Magazine", 
		"Your magazine is HUGE.", 
		{"max_bullets": +50}, 
		[])

onready var life_steal_card: BaseCard = base_card.new("Life Steal", 
		"When you hit an enemy with a bullet you get healed by the amount of damage caused.", 
		{}, 
		[CommandsRepository.steal_health_command])

onready var cards: Array = [
	tank_card,
	huge_magazine_card,
	life_steal_card
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
	
	var idx3 = randi() % cards_size-2
	while idx3 == idx1 or idx3 == idx2:
		idx3 = randi() % cards_size-2
		
	return [cards[idx1], cards[idx2], cards[idx3]]