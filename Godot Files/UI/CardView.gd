extends Control

signal selected(card)

onready var name_label = $CardContainer/Name
onready var description_label = $CardContainer/Description

var card: BaseCard

func _ready():
	name_label.text = card.card_name
	description_label.text = card.card_description


func _on_Button_pressed():
	emit_signal("selected", card)
