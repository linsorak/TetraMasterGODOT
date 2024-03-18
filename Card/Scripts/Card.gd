extends Area2D
class_name Card

enum COLOR {
	BLUE,
	RED
}

@export var width: float = 150.0
@export var height: float = 150.0
@export var color: COLOR = COLOR.BLUE

var background = Sprite2D.new()
var illustration = Sprite2D.new()
var border = Sprite2D.new()
var _card_sheet : Texture
var _illustration_img : Texture
var _arrow_img : Texture
var arrows : Array[Sprite2D]
var drag_position = Vector2.ZERO
var numbers: Array[String]

var _scale_w: float
var _scale_h: float
var _selected = false
var _can_be_selected = false : set = set_can_be_selected, get = get_can_be_selected

signal card_selected(selected_card)
signal card_unselected(selected_card)

func _init():
	_card_sheet = preload("res://Card/Sprites/TetraMasterCardAssets.png")
	_illustration_img = preload("res://Card/Sprites/illustrations.png")
	_arrow_img = preload("res://Card/Sprites/arrow.png")
	width = _illustration_img.get_width()
	height = _illustration_img.get_height()
	add_child(background)
	add_child(illustration)
	add_child(border)	

func _ready():
	connect("input_event", Callable(self, "_on_card_click"))
	

func initialize(card_color: COLOR, card_arrows: Array[bool], card_numbers: Array[String], card_illustration: Array[int], case_dimensions: Vector2) -> void:
	color = card_color
	numbers = card_numbers
	update_color()
	_scale_w = case_dimensions.x / border.get_rect().size.x 
	_scale_h = case_dimensions.y / border.get_rect().size.y	
	processing_arrows()
	set_arrows(card_arrows)
	initialize_numbers()
	place_numbers()
	rescale()
	set_illustration(card_illustration[0], card_illustration[1])
	var collision_shape = $CollisionShape2D.shape as RectangleShape2D
	if collision_shape == null:
		collision_shape = RectangleShape2D.new()
		$CollisionShape2D.shape = collision_shape
		
	collision_shape.extents = Vector2(border.get_rect().size.x, border.get_rect().size.y) / 2
	$CollisionShape2D.position = Vector2(get_width(), get_height()) / 2 

func rescale() -> void:
	for child in get_children():
		if child is Sprite2D:
			child.centered = false
		child.scale = Vector2(_scale_w, _scale_h)

func set_illustration(x: int, y: int) -> void:
	var sheet_row_width = int(_illustration_img.get_width() / 12.0)
	var sheet_column_height = int(_illustration_img.get_height() / 9.0)
	var position_x = sheet_row_width * x
	var position_y = sheet_column_height * y
	var region_illustration = Rect2(Vector2(position_x, position_y), Vector2(sheet_row_width, sheet_column_height))
	_add_texture(_illustration_img, illustration, region_illustration)
	illustration.region_enabled = true
	var scale_w = (border.get_rect().size.x * _scale_w) / sheet_row_width
	var scale_h = (border.get_rect().size.y * _scale_h) / sheet_column_height
	illustration.scale = Vector2(scale_w, scale_h)


func update_color() -> void:
	var sheet_row_width = _card_sheet.get_width() / 4.0
	var sheet_column_height = _card_sheet.get_height() / 2.0
	var position_color_x = sheet_row_width * color
	var position_color_y = sheet_column_height
	var position_border_x = position_color_x
	var position_border_y = 0
	var region_color = Rect2(Vector2(position_color_x, position_color_y), Vector2(sheet_row_width, sheet_column_height))
	var region_border = Rect2(Vector2(position_border_x, position_border_y), Vector2(sheet_row_width, sheet_column_height))

	_add_texture(_card_sheet, background, region_color)
	_add_texture(_card_sheet, border, region_border)


func set_arrows(card_arrows: Array[bool]) -> void:
	var arrow_data = ["top_left","top_middle", "top_right", "midle_left", "midle_right", "bottom_left", "bottom_middle", "bottom_right"]
	for i in range(len(card_arrows)):
		var arrow = get_node(arrow_data[i])
		if arrow:
			arrow.visible = card_arrows[i]

func processing_arrows() -> void:
	var arrow_data = [
		{"position": Vector2(115 * _scale_w, 32 * _scale_h), "rotation": 135, "name": "top_left"},
		{"position": Vector2(371 * _scale_w, 80 * _scale_h), "rotation": 180, "name": "top_middle"},
		{"position": Vector2(595 * _scale_w, 118 * _scale_h), "rotation": 225, "name": "top_right"},
		{"position": Vector2(76 * _scale_w, 348 * _scale_h), "rotation": 90, "name": "midle_left"},
		{"position": Vector2(549 * _scale_w, 465 * _scale_h), "rotation": 270, "name": "midle_right"},
		{"position": Vector2(31 * _scale_w, 696 * _scale_h), "rotation": 45, "name": "bottom_left"},
		{"position": Vector2(253 * _scale_w, 733 * _scale_h), "rotation": 0, "name": "bottom_middle"},
		{"position": Vector2(510 * _scale_w, 780 * _scale_h), "rotation": 315, "name": "bottom_right"}
	]	

	for i in range(len(arrow_data)):
		var arrow = Sprite2D.new()
		var temp_texture = preload("res://Card/Sprites/arrow.png")	
		arrow.centered = false
		arrow.texture = temp_texture
		arrow.name = arrow_data[i]["name"]
		arrow.position = arrow_data[i]["position"]
		arrow.rotate(deg_to_rad(arrow_data[i]["rotation"]))
		add_child(arrow)

func initialize_numbers() -> void:
	var attack_force = _generate_number(numbers[0])
	var attack_type = _generate_number(numbers[1])
	var physical_defense = _generate_number(numbers[2])
	var magical_defense = _generate_number(numbers[3])

	attack_force.name = "attack_force"
	attack_type.name = "attack_type"
	physical_defense.name = "physical_defense"
	magical_defense.name = "magical_defense"

	add_child(attack_force)
	add_child(attack_type)
	add_child(physical_defense)
	add_child(magical_defense)

func place_numbers() -> void:
	var nodes = ["attack_force", "attack_type", "physical_defense", "magical_defense"]
	var sizes = []
	var heights = []
	var positions = []
	var space_between_number = 20 * ((_scale_w + _scale_h) / 2)
	var total_sizes = 0
	var width_card = border.region_rect.size.x * _scale_w


	for node in nodes:
		var node_ref = get_node(node)
		if node_ref:
			var node_size = node_ref.get_size().x * _scale_w
			var node_height = node_ref.get_size().y * _scale_h
			sizes.append(node_size)
			heights.append(node_height)
			total_sizes += node_size

	var space_between_card_total_sizes = width_card - total_sizes
	var offset_size = (space_between_card_total_sizes / 2) - ((space_between_number * 3) / 2)

	for i in range(len(nodes)):
		var sum_size = 0
		for j in range(i):
			sum_size = sum_size + sizes[j]

		var offset = offset_size + (space_between_number * i) + sum_size
		positions.append(offset)

	var border_height = border.region_rect.size.y * _scale_h
	var position_value = 0

	for value in positions:
		position_value += value
	position_value = position_value / len(positions)
	var offset_top = border_height - position_value

	for i in range(len(nodes)):
		get_node(nodes[i]).position = Vector2(positions[i], offset_top)

func _add_texture(img: Texture, sprite: Sprite2D, region: Rect2) -> void:
	var image = img.get_image()
	var temp_texture = ImageTexture.create_from_image(image)
	sprite.texture = temp_texture
	sprite.region_enabled = true
	sprite.region_rect = region


func _generate_number(number_value: String) -> Label:
	var number = Label.new()
	var number_font = load("res://Fonts/kimberley.ttf")
	number.add_theme_font_override("font", number_font)
	number.add_theme_font_size_override("font_size", 125)
	number.add_theme_color_override("font_color", Color("F4AF11"))
	number.add_theme_color_override("font_outline_color", Color("000000"))
	number.add_theme_constant_override("outline_size", 35)
	number.text = number_value
	return number

func get_height() -> float:
	return border.region_rect.size.y * _scale_h	
	
func get_width() -> float:
	return border.region_rect.size.x * _scale_w
	
func set_can_be_selected(value: bool) -> void:
	_can_be_selected = value
	
func get_can_be_selected() -> bool:
	return _can_be_selected

func _on_card_click(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if get_can_be_selected():
			if _selected:
				emit_signal("card_unselected", self)
				_selected = false
			else:
				emit_signal("card_selected", self)
				_selected = true
		else:
			print("Can't be selected")
