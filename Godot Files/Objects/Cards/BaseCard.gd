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
	for key in attribute_changes.keys():
		if player.get(key):
			match attribute_changes[key][0]:
				"*":
					player[key] *= attribute_changes[key][1]
				"+":
					player[key] += attribute_changes[key][1]
	player["bullet_on_hit"].append_array(on_hit)
	if player.get("cards"):
		player["cards"].append(self)
