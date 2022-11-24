extends Node
class_name BaseCard

var card_name: String
var card_description: String

var attribute_changes: Dictionary
var on_hit: Array

func _init(name_: String, description_: String, attributes_: Dictionary, on_hit_: Array):
	card_name = name_
	card_description = description_
	attribute_changes = attributes_
	on_hit = on_hit_

func attach_to_player(player: KinematicBody):
	print("Attaching a card: ", card_name)
	for key in attribute_changes.keys():
		if player.get(key):
			player[key] += attribute_changes[key]
	# if player.get("bullet_on_hit"):
	player["bullet_on_hit"].append_array(on_hit)
	print(player["bullet_on_hit"].size(), " on hit events attached")
	if player.get("cards"):
		player["cards"].append(self)
