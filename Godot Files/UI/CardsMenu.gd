extends Control

onready var select_button = $Button
onready var cards_container = $CardsContainer
onready var card_view_scene = preload("res://UI/CardView.tscn")

var selected_card = null

func _ready():
	select_button.hide()
	randomize()
	var cards = CardsRepository.get_3random_cards()
	for card in cards:
		# print("choice: ", card)
		var card_view = card_view_scene.instance()
		card_view.card = card
		card_view.connect("preselected", self, "_card_selected")
		cards_container.add_child(card_view)

func _card_selected(card: BaseCard):
	selected_card = card
	select_button.visible = true
	select_button.text = "Select %s" % card.card_name
	
func _on_Button_pressed():
	GameState.selected_card(selected_card)
	
