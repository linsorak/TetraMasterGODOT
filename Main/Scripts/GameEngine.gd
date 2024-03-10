extends Node2D

func _ready():
	generate_deck()
	
func generate_deck() -> void:
	var arrows: Array[bool] = [false, true, false, true, false, true, false, true]
	var numbers: Array[String] = ["1", "X", "D", "A"]
	var illustration: Array[int] = [0, 5]
	var card = generate_card()
	var card2 = generate_card()
	add_child(card)
	add_child(card2)
	card.global_position = Vector2(100, 100)
	card.initiliaze(Card.COLOR.RED, arrows, numbers, illustration)
	card2.initiliaze(Card.COLOR.BLUE, arrows, numbers, illustration)

func generate_card() -> Card:
	var base_card = load("res://Card/Scenes/Card.tscn")	
	var card = base_card.instantiate() as Card
	
	return card
	
