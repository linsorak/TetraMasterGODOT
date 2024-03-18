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
		processing_game(selected_case)
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

	#Haut Gauche, Haut, Haut Droite, Gauche, Droite, Bas Gauche, Bas, Bas Droite
	if number_x > 0 and number_y > 0:
		nearest_cases.append(%Board.get_node("Case_" + str(number_x - 1) + "_" + str(number_y - 1))) # Haut Gauche
	else:
		nearest_cases.append(null)

	if number_x > 0:
		nearest_cases.append(%Board.get_node("Case_" + str(number_x - 1) + "_" + str(number_y))) # Haut
	else:
		nearest_cases.append(null)

	if number_x > 0 and number_y < max_cases_y - 1:
		nearest_cases.append(%Board.get_node("Case_" + str(number_x - 1) + "_" + str(number_y + 1))) # Haut Droite
	else:
		nearest_cases.append(null)

	if number_y > 0:
		nearest_cases.append(%Board.get_node("Case_" + str(number_x) + "_" + str(number_y - 1))) # Gauche
	else:
		nearest_cases.append(null)

	if number_y < max_cases_y - 1:
		nearest_cases.append(%Board.get_node("Case_" + str(number_x) + "_" + str(number_y + 1))) # Droite
	else:
		nearest_cases.append(null)

	if number_x < max_cases_x - 1 and number_y > 0:
		nearest_cases.append(%Board.get_node("Case_" + str(number_x + 1) + "_" + str(number_y - 1))) # Bas Gauche
	else:
		nearest_cases.append(null)

	if number_x < max_cases_x - 1:
		nearest_cases.append(%Board.get_node("Case_" + str(number_x + 1) + "_" + str(number_y))) # Bas
	else:
		nearest_cases.append(null)

	if number_x < max_cases_x - 1 and number_y < max_cases_y - 1:
		nearest_cases.append(%Board.get_node("Case_" + str(number_x + 1) + "_" + str(number_y + 1))) # Bas Droite
	else:
		nearest_cases.append(null)

	return nearest_cases
	
func get_opposite_direction(direction: int) -> int:
	match direction:
		0: return 7 # Haut Gauche - Bas Droite
		1: return 6 # Haut - Bas
		2: return 5 # Haut Droite - Bas Gauche
		3: return 4 # Gauche - Droite
		4: return 3 # Droite - Gauche
		5: return 2 # Bas Gauche - Haut Droite
		6: return 1 # Bas - Haut
		7: return 0 # Bas Droite - Haut Gauche
	return -1 
		
func processing_game(current_case: Case, is_combo = false) -> void:
	var nearest_cases = get_nearest_cases(current_case)
	var case_item = current_case.get_item()
	var cases_fight = []
	
	if case_item is Card:
		for i in range(len(case_item.arrows)):
			var arrow = case_item.arrows[i]
			
			if arrow.visible:
				var opposite_direction = get_opposite_direction(i)
				var direction_case = nearest_cases[i]
				
				if direction_case:
					var direction_case_item = direction_case.get_item()
					
					if direction_case_item is Card and direction_case_item.color != _current_player:
						if direction_case_item.arrows[opposite_direction].visible == false:
							direction_case_item.change_color(_current_player)
							print(direction_case_item.get_power(direction_case_item.numbers[0]))
						else:
							if not is_combo:
								cases_fight.append(direction_case_item)
		
	
