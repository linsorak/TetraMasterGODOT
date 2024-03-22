extends Node2D

class_name Board


var case_width = 182
var case_height = 235
var num_rows = 4
var num_cols = 4
var spacing = 6 

var background_image : String = "res://Board/Sprites/board.png"
var blue_deck: Array[Card]
var red_deck: Array[Card]
var cases: Array[Case]

var cursor_scene: PackedScene
var cursor: AnimatedSprite2D

var coin_scene: PackedScene
var coin: AnimatedSprite2D

func _ready():
	pass
	
func init_board() -> void:	
	var ratio = get_viewport_rect().size.x / 1920
	case_width *= ratio
	case_height *= ratio
	_clear_children()
	_set_board_background_img()
	var grid_width = (case_width + spacing) * num_cols - spacing
	var grid_height = (case_height + spacing) * num_rows - spacing 
	var screen_size = get_viewport_rect().size
	var start_x = (screen_size.x - grid_width) / 2
	var start_y = (screen_size.y - grid_height) / 2
	var base_case = load("res://Board/Case/Scenes/Case.tscn")
	for row in range(num_rows):
		for col in range(num_cols):
			var case_instance = base_case.instantiate()
			var case_position = Vector2(start_x + col * (case_width + spacing), start_y + row * (case_height + spacing))
			case_instance.position = case_position
			case_instance.set_size(Vector2(case_width, case_height))
			case_instance.name = "Case_" + str(row) + "_" + str(col) 
			add_child(case_instance)
			cases.append(case_instance)
	_generate_blocks()
	_generate_decks(Card.COLOR.BLUE, blue_deck)
	_generate_decks(Card.COLOR.RED, red_deck)
	cursor_scene = load("res://Board/Cursor/Scenes/Cursor.tscn")
	cursor = cursor_scene.instantiate()
	cursor.visible = false
	add_child(cursor)
	
	coin_scene = load("res://Board/Coin/Scenes/Coin.tscn")
	coin = coin_scene.instantiate()
	coin.visible = false
	add_child(coin)	
	
			
func _generate_blocks() -> void:
	var nb_blocks = randi_range(0, 6)
	var base_block = load("res://Board/Block/Scenes/Block.tscn")
	var selected_blocks_list = []
	
	for i in range(nb_blocks):
		var random_position = Vector2(randi() % num_rows, randi() % num_cols)		
		while selected_blocks_list.find(random_position) != -1:
			random_position = Vector2(randi() % num_rows, randi() % num_cols)
		
		selected_blocks_list.append(random_position)
		var block = base_block.instantiate()
		add_child(block)
		block.rescale(Vector2(case_width, case_height))
		var case = get_node("Case_" + str(random_position.x) + "_" + str(random_position.y))		
		if case:
			block.position = case.position
			case.set_item(block)		
			
func _generate_card(color: Card.COLOR) -> Card:
	var base_card = load("res://Card/Scenes/Card.tscn")
	var card = base_card.instantiate() as Card	
	add_child(card)
	var random_illustration_x = randi() % 12 
	var random_illustration_y = randi() % 8 
	var illustration : Array[int] = [random_illustration_x, random_illustration_y]
	var random_arrows : Array[bool] = []
	for _i in range(8):
		random_arrows.append(randi() % 2 == 0)

	var random_numbers: Array[String] = []
	for _i in range(4):
		var random_digit = randi() % 16
		var hex_digit = "0123456789ABCDEF"[random_digit]
		if _i == 1:
			random_digit = randi() % 4
			hex_digit = "PMXA"[random_digit]
		random_numbers.append(hex_digit)
		
	card.global_position = Vector2(90, 100)
	card.initialize(color, random_arrows, random_numbers, illustration, Vector2(case_width, case_height))
	return card
	
func _generate_decks(color: Card.COLOR, deck: Array[Card]) -> void:
	var screen_size = get_viewport_rect().size
	var offset = (screen_size.y - (case_height * 3)) / 2
	var case = null
	var position_x = null
	if color == Card.COLOR.BLUE:
		case = get_node("Case_0_3")
		position_x = case.position.x + (((screen_size.x - case.position.x) / 2) - case_width * 1.5)
	else:
		case = get_node("Case_0_0")
		position_x = (case.position.x / 2.0) - (case_width + case_width / 2.0)

			
	for i in range(5):
		var card = _generate_card(color)
		deck.append(card)
		var card_height = card.get_height()
		var x_pos = null
		var y_pos = null		
		if color == Card.COLOR.BLUE:
			x_pos = position_x + card.get_width() 
			y_pos = i * (card_height / 2) + offset
			if i % 2:
				x_pos = x_pos + card.get_width()
		else:
			x_pos = position_x + (card.get_width() * 1.5)
			y_pos = i * (card_height / 2) + offset
			if i % 2:
				x_pos = x_pos - card.get_width()
		card.global_position = Vector2(x_pos, y_pos)
			
func _set_board_background_img() -> void:
	var image = Sprite2D.new()
	var texture = load(background_image)
	var texture_size = texture.get_size()
	var screen_size = get_viewport_rect().size	
	var target_height = screen_size.y
	var scale_factor = target_height / texture_size.y
	image.texture = texture
	image.scale = Vector2(scale_factor, scale_factor)
	var image_size = texture_size * scale_factor
	image.position.x = (screen_size.x - image_size.x) / 2 + (image_size.x / 2)
	image.position.y = (screen_size.y - image_size.y) / 2 + (image_size.y / 2) 		
	add_child(image)

func _clear_children():
	for child in get_children():
		child.queue_free()

func _on_game_engine_current_player(current_player):
	var blue_can_be_selected = false
	var red_can_be_selected = false
	if current_player == Card.COLOR.BLUE:
		blue_can_be_selected = true
	elif current_player == Card.COLOR.RED:
		red_can_be_selected = true
		
	for card in blue_deck:
		card.set_can_be_selected(blue_can_be_selected)
		
	for card in red_deck:
		card.set_can_be_selected(red_can_be_selected) 
			
