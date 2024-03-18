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
	connect_cases(%Board.cases)
	var num_colors = Card.COLOR.values().size()
	var random_index = randi() % num_colors
	_current_player = Card.COLOR.values()[random_index]		
	emit_signal("current_player", _current_player)
	
func connect_cards(deck: Array[Card]) -> void:
	for card in deck:
		card.connect("card_selected", Callable(self, "_on_card_selected"))	
		card.connect("card_unselected", Callable(self, "_on_card_unselected"))			
		
func connect_cases(cases: Array[Case]) -> void:
	for case in cases:
		case.connect("case_can_be_selected", Callable(self, "_on_case_can_be_selected"))	
		case.connect("case_clicked", Callable(self, "_on_case_clicked"))	
		
func connect_to_board():
	if %Board:
		%Board.connect("board_ready", Callable(self, "_on_card_selected"))
	
func _on_card_selected(selected_card) -> void:
	_selected_card = selected_card
	print("Carte sélectionnée :", selected_card.numbers)
	
func _on_card_unselected(selected_card) -> void:
	_selected_card = null
	unselect_cases()
	print("Carte désélectionnée :", selected_card.numbers)
	
func _on_case_can_be_selected(selected_case) -> void:
	if _selected_card && selected_case.get_item() == null:
		unselect_cases()
		selected_case.set_selected(true)

func _on_case_clicked(selected_case) -> void:
	if _selected_card && selected_case.get_item() == null:
		selected_case.set_item(_selected_card)
		_selected_card.set_can_be_selected(false)
		_selected_card.set_selected(false)		
		_selected_card.position = selected_case.position
		_selected_card = null
		unselect_cases()
		print(get_nearest_cases(selected_case))
		print(_current_player)
		if _current_player == Card.COLOR.BLUE:
			_current_player = Card.COLOR.RED
		else:
			_current_player = Card.COLOR.BLUE
		emit_signal("current_player", _current_player)

func unselect_cases() -> void:
	for case in %Board.cases:
		case.set_selected(false)
		
func get_nearest_cases(case: Case) -> Array:
	var nearest_cases = []
	var max_cases_x = %Board.num_rows
	var max_cases_y = %Board.num_cols

	var numbers = case.name.split("_")
	var number_x = int(numbers[1])
	var number_y = int(numbers[2])

	if number_x > 0:
		nearest_cases.append(%Board.get_node("Case_" + str(number_x - 1) + "_" + str(number_y)))
	else:
		nearest_cases.append(null)

	if number_x < max_cases_x - 1:
		nearest_cases.append(%Board.get_node("Case_" + str(number_x + 1) + "_" + str(number_y)))
	else:
		nearest_cases.append(null)

	if number_y > 0:
		nearest_cases.append(%Board.get_node("Case_" + str(number_x) + "_" + str(number_y - 1)))
	else:
		nearest_cases.append(null)

	if number_y < max_cases_y - 1:
		nearest_cases.append(%Board.get_node("Case_" + str(number_x) + "_" + str(number_y + 1)))
	else:
		nearest_cases.append(null)

	return nearest_cases
		
func processing_game(case: Case) -> void:
	pass
	
