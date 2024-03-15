extends Node2D

class_name Board

var case_width = 182
var case_height = 235
var num_rows = 4
var num_cols = 4
var spacing = 6 

var background_image : String = "res://Board/Sprites/board.png"

func _ready():
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
	_generate_blocks()
			
func _generate_blocks() -> void:
	var nb_blocks = randi_range(0, 5)
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





