extends Node2D
class_name GameEngine

const NUM_CARDS: int = 5
var _selected_card: Card
var _current_player: Card.COLOR

var queue_combos_fights = []
var queue_fights = []

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
		
func unselect_card(ignored_card: Card) -> void:
	for card in %Board.blue_deck:
		if card != ignored_card:
			card.set_selected(false)
			
	for card in %Board.red_deck:
		if card != ignored_card:
			card.set_selected(false)
	
func _on_card_selected(selected_card) -> void:
	_selected_card = selected_card
	unselect_cases()
	%Board.cursor.visible = true
	%Board.cursor.play()
	%Board.cursor.position.y = selected_card.position.y + selected_card.get_height() / 2
	%Board.cursor.position.x = selected_card.position.x	
	unselect_card(selected_card)
	print("Carte sélectionnée :", selected_card.numbers)
	
func _on_card_unselected(selected_card) -> void:
	_selected_card = null
	unselect_cases()	
	%Board.cursor.visible = false	
	%Board.cursor.stop()	
	unselect_card(selected_card)
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
		%Board.cursor.stop()
		%Board.cursor.visible = false		
		selected_case.hide_border()

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
	queue_fights = []
	queue_combos_fights = []
	
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
							#direction_case_item.change_color(_current_player)
							var data = {
								"current_card": case_item,
								"defense_card": direction_case_item,
								"direction": i,
								"opposite_direction": opposite_direction
							}
							queue_fights.append(data)
						else:
							if not is_combo:
								var data = {
									"current_card": case_item,
									"defense_card": direction_case_item,
									"direction": i,
									"opposite_direction": opposite_direction
								}
								queue_combos_fights.append(data)
								
		if len(queue_combos_fights) > 1:
			#_processing_combo(queue_combos_fights)
			_ask_choose_card()
			
func _ask_choose_card() -> void:
	var defense_cards = []
	var current_card = null
	for choose_card_data in queue_combos_fights:
		if choose_card_data["defense_card"] != null:
			defense_cards.append(choose_card_data["defense_card"])
			current_card = choose_card_data["current_card"]
			
	for case in %Board.cases:
		if case.get_item() is Card:
			if case.get_item() not in defense_cards and case.get_item() != current_card and case.get_item().get_node("masking_rect").visible == false:
				case.get_item().get_node("masking_rect").visible = true

		
								
func _processing_combo(queue: Array) -> void:
	#P : Attaque physique.
	#M : Attaque magique.
	#X : Utilise la défense la plus faible de la carte adverse.
	#A : Utilise le meilleur attribut de la carte en tant que puissance d'attaquer, et utilise l'attribut le plus faible de la carte adverse comme défense.	
	for fight in queue:
		var current_card = fight["current_card"]
		var defense_card = fight["defense_card"]
		var direction = fight["direction"]
		var opposite_direction = fight["opposite_direction"]
		
		if current_card.arrows[direction].visible and defense_card.arrows[opposite_direction].visible:		
			var attacking_card_attack_force = current_card.get_node("attack_force")
			var attacking_card_attack_type = current_card.get_node("attack_type")
			var attacking_card_physical_defense = current_card.get_node("physical_defense")
			var attacking_card_magical_defense = current_card.get_node("magical_defense")
			var defense_card_attack_force = defense_card.get_node("attack_force")
			var defense_card_physical_defense = defense_card.get_node("physical_defense")
			var defense_card_magical_defense = defense_card.get_node("magical_defense")
			
			var attacking_card_attack = null
			var attacking_card_attack_power = null
			var defense_card_defense = null
			var defense_card_defense_power = null
			
			match attacking_card_attack_type.text:
				"P": 
					attacking_card_attack = attacking_card_attack_force.text
					defense_card_defense = defense_card_physical_defense.text		
				"M": 
					attacking_card_attack = attacking_card_attack_force.text
					defense_card_defense = defense_card_magical_defense.text
				"X": 
					attacking_card_attack = attacking_card_attack_force.text
					var hex_value_defense_card_physical_defense = defense_card_physical_defense.text.hex_to_int()
					var hex_value_defense_card_magical_defense = defense_card_magical_defense.text.hex_to_int()
					if hex_value_defense_card_physical_defense <= hex_value_defense_card_magical_defense:
						defense_card_defense = defense_card_physical_defense.text
					else:
						defense_card_defense = defense_card_magical_defense.text
				"A":
					var hex_value_attacking_card_attack_force = attacking_card_attack_force.text.hex_to_int()
					var hex_value_attacking_card_physical_defense = attacking_card_physical_defense.text.hex_to_int()
					var hex_value_attacking_card_magical_defense = attacking_card_magical_defense.text.hex_to_int()
					
					if hex_value_attacking_card_attack_force >= hex_value_attacking_card_physical_defense:
						attacking_card_attack = attacking_card_attack_force.text
					elif hex_value_attacking_card_physical_defense >= hex_value_attacking_card_magical_defense:
						attacking_card_attack = attacking_card_physical_defense.text
					else:
						attacking_card_attack = attacking_card_magical_defense.text					
					
					var hex_value_defense_card_attack_force = defense_card_attack_force.text.hex_to_int()
					var hex_value_defense_card_physical_defense =defense_card_physical_defense.text.hex_to_int()
					var hex_value_defense_card_magical_defense = defense_card_magical_defense.text.hex_to_int()
					if hex_value_defense_card_attack_force <= hex_value_defense_card_physical_defense:
						defense_card_defense = defense_card_attack_force.text
					elif hex_value_defense_card_physical_defense <= hex_value_defense_card_magical_defense:
						defense_card_defense = defense_card_physical_defense.text
					else:
						defense_card_defense = defense_card_magical_defense.text			
			
			attacking_card_attack_power = current_card.calculate_power(attacking_card_attack)			
			defense_card_defense_power = defense_card.calculate_power(defense_card_defense)		
			if attacking_card_attack_power["power"] >= defense_card_defense_power["power"]:
				defense_card.change_color(current_card.color)
			else:
				current_card.change_color(defense_card.color)

