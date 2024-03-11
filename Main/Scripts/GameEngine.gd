extends Node2D

const NUM_CARDS: int = 5

func _ready():
	generate_deck()

func generate_deck() -> void:
	for i in range(NUM_CARDS):
		var card = generate_card()
		add_child(card)
		card.global_position = Vector2(90 + i * 200, 100)

		var random_color = randi() % len(Card.COLOR) 
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
			random_numbers.append(hex_digit)
			
		#card.initiliaze(random_color, random_arrows, random_numbers, illustration)
		card.initialize(random_color, random_arrows, random_numbers, illustration)
		card.connect("card_drag_started", Callable(self, "_on_card_drag_started"))


func generate_card() -> Card:
	var base_card = load("res://Card/Scenes/Card.tscn")
	var card = base_card.instantiate() as Card
	return card

func _on_card_drag_started(card_instance):
	for child in get_children():
		if child != card_instance:
			child.dragging = false
