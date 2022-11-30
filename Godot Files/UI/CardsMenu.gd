extends Control

onready var cards_container = $CardsContainer
onready var card_view_scene = preload("res://UI/CardView.tscn")

func _ready():
	var cards = CardsRepository.get_3random_cards()
	for card in cards:
		var card_view = card_view_scene.instance()
		card_view.card = card
		card_view.connect("selected", self, "_card_selected")
		cards_container.add_child(card_view)

func _card_selected(card: BaseCard):
	GameState.selected_card(card)