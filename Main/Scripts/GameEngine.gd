extends Node2D
class_name GameEngine

const NUM_CARDS: int = 5
var _selected_card: Card
var _current_player: Card.COLOR

signal current_player(_current_player: Card.COLOR)

func _ready():
	new_game()
	
func new_game() -> void:
	%Board.init_board()
	connect_cards(%Board.blue_deck)
	connect_cards(%Board.red_deck)	
	var num_colors = Card.COLOR.values().size()
	var random_index = randi() % num_colors
	_current_player = Card.COLOR.values()[random_index]		
	emit_signal("current_player", _current_player)
	
func connect_cards(deck: Array[Card]) -> void:
	for card in deck:
		card.connect("card_selected", Callable(self, "_on_card_selected"))	
		card.connect("card_unselected", Callable(self, "_on_card_unselected"))			
		
func connect_to_board():
	if %Board:
		%Board.connect("board_ready", Callable(self, "_on_card_selected"))
	
func _on_card_selected(selected_card) -> void:
	_selected_card = selected_card
	print("Carte sélectionnée :", selected_card.numbers)
	
func _on_card_unselected(selected_card) -> void:
	_selected_card = null
	print("Carte désélectionnée :", selected_card.numbers)
