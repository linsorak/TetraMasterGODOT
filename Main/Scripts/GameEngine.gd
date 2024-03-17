extends Node2D
class_name GameEngine

const NUM_CARDS: int = 5

func _ready():
	new_game()
	
func new_game() -> void:
	%Board.init_board()
	connect_cards(%Board.blue_deck)
	connect_cards(%Board.red_deck)
	
func connect_cards(deck: Array[Card]) -> void:
	for card in deck:
		card.connect("card_selected", Callable(self, "_on_card_selected"))	
		
func connect_to_board():
	if %Board:
		%Board.connect("board_ready", Callable(self, "_on_card_selected"))
	
func _on_card_selected(selected_card) -> void:
	print("Carte sélectionnée :", selected_card.numbers)
