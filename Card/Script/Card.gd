extends CharacterBody2D
class_name Card

enum COLOR {
	BLUE,
	RED,
	GREEN,
	PURPLE
}

@export var width: float = 150.0
@export var height: float = 150.0
@export var scale_value: float = 0.3
@export var color: COLOR = COLOR.BLUE

var background = Sprite2D.new()
var illustration = Sprite2D.new()
var border = Sprite2D.new()
var _card_sheet = Image.new()
var _illustration_img = Image.new()
var _arrow_img = Image.new()
var arrows : Array[Sprite2D]
var drag_position = Vector2.ZERO
var dragging = false
var numbers: Array[String]


func _init():
	_card_sheet.load("res://Card/Sprites/TetraMasterCardAssets.png")		
	_illustration_img.load("res://Card/Sprites/illustrations.png")
	_arrow_img.load("res://Card/Sprites/arrow.png")
	width = _illustration_img.get_width()
	height = _illustration_img.get_height()
	add_child(background)
	add_child(illustration)
	add_child(border)	
	processing_arrows()
	
func _ready():	
	pass

	
func initiliaze(card_color: COLOR, card_arrows: Array[bool], card_numbers: Array[String], card_illustration: Array[int]) -> void:	
	print("initiliaze")
	set_arrows(card_arrows)
	color = card_color	
	numbers = card_numbers	
	update_color()
	initialize_numbers()
	place_numbers()		
	rescale()
	set_illustration(card_illustration[0], card_illustration[1])	
	
func rescale() -> void:
	for child in get_children():
		if child is Sprite2D:
			child.centered = false  # Centre le sprite
		child.scale = Vector2(scale_value, scale_value)
			
			
func set_illustration(x: int, y: int) -> void:
	var sheet_row_width = int(_illustration_img.get_width() / 12.0)
	var sheet_column_height = int(_illustration_img.get_height() / 9.0)	
	var position_x = sheet_row_width * x
	var position_y = sheet_column_height * y
	var region_illustration = Rect2(Vector2(position_x, position_y), Vector2(sheet_row_width, sheet_column_height))
	_add_texture(_illustration_img, illustration, sheet_row_width, sheet_column_height, region_illustration)
	var scale_w = (border.get_rect().size.x * scale_value) / sheet_row_width 
	var scale_h = (border.get_rect().size.y * scale_value) / sheet_column_height
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
	
	_add_texture(_card_sheet, background, sheet_row_width, sheet_column_height, region_color)
	_add_texture(_card_sheet, border, sheet_row_width, sheet_column_height, region_border)

func set_arrows(card_arrows: Array[bool]) -> void:
	var arrow_data = ["top_left","top_middle", "top_right", "midle_left", "midle_right", "bottom_left", "bottom_middle", "bottom_right"]	
	for i in range(len(card_arrows)):
		var arrow = get_node(arrow_data[i])
		if arrow:
			arrow.visible = card_arrows[i]
		
func processing_arrows() -> void:
	var arrow_data = [
		{"position": Vector2(115, 32), "rotation": 135, "name": "top_left"},
		{"position": Vector2(371, 80), "rotation": 180, "name": "top_middle"},
		{"position": Vector2(595, 118), "rotation": 225, "name": "top_right"},
		{"position": Vector2(76, 348), "rotation": 90, "name": "midle_left"},
		{"position": Vector2(549, 465), "rotation": 270, "name": "midle_right"},
		{"position": Vector2(31, 696), "rotation": 45, "name": "bottom_left"},
		{"position": Vector2(253, 733), "rotation": 0, "name": "bottom_middle"},
		{"position": Vector2(510, 780), "rotation": 315, "name": "bottom_right"}
	]
	
	for i in range(len(arrow_data)):
		var arrow = Sprite2D.new()		
		var temp_texture = ImageTexture.create_from_image(_arrow_img)
		arrow.texture = temp_texture
		arrow.name = arrow_data[i]["name"]
		arrow.position = arrow_data[i]["position"] * scale_value
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
	var space_between_number = 20 * scale_value
	var total_sizes = 0
	var width_card = border.texture.get_size().x * scale_value
	
	for node in nodes:
		var node_ref = get_node(node)
		if node_ref:
			var node_size = node_ref.get_size().x * scale_value
			var node_height = node_ref.get_size().y * scale_value
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
		
	var border_height = border.texture.get_size().y * scale_value
	var position_value = 0
	
	for value in positions:
		position_value += value
	position_value = position_value / len(positions)
	var offset_top = border_height - position_value
	
	
	for i in range(len(nodes)):
		get_node(nodes[i]).position = Vector2(positions[i], offset_top)		

func _add_texture(img: Image, sprite: Sprite2D, _width: float, _height: float, region: Rect2) -> void:
	var temp_img = Image.create(int(_width), int(_height), false, img.get_format())
	temp_img.fill(Color(0, 0, 0, 0)) 
	temp_img.blit_rect(img, region, Vector2(0, 0))
	var temp_texture = ImageTexture.create_from_image(temp_img)
	sprite.texture = temp_texture

func _generate_number(number_value: String) -> Label:
	var number = Label.new()
	var number_font = load("res://Fonts/kimberley.ttf")
	number.add_theme_font_override("font", number_font)
	number.add_theme_font_size_override("font_size", 140)
	number.add_theme_color_override("font_color", Color("F4AF11"))
	number.add_theme_color_override("font_outline_color", Color("000000"))
	number.add_theme_constant_override("outline_size", 40)
	number.text = number_value
	return number

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT: 
			if event.is_pressed():
				var mouse_pos = get_global_mouse_position()
				var border_size = border.texture.get_size() * scale_value
				var border_rect = Rect2(global_position.x, global_position.y, border_size.x, border_size.y)
				if border_rect.has_point(mouse_pos):
					dragging = true
					drag_position = mouse_pos - global_position
					set_as_top_level(true) 
			else:
				dragging = false
				set_as_top_level(false)
	elif event is InputEventMouseMotion:
		if dragging:
			global_position = get_global_mouse_position() - drag_position
