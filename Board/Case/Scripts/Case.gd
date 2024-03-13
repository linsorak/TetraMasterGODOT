class_name Case
extends Area2D

var border_size = 2

func _ready():
	$Panel.connect("mouse_entered", Callable(self, "_on_case_mouse_entered"))
	$Panel.connect("mouse_exited", Callable(self, "_on_case_mouse_exited"))

func set_size(case_size: Vector2) -> void:
	$Panel.size = case_size
	var collision_shape = $CollisionShape2D.shape as RectangleShape2D
	if collision_shape == null:
		collision_shape = RectangleShape2D.new()
		$CollisionShape2D.shape = collision_shape
		
	collision_shape.extents = case_size / 2
	$CollisionShape2D.position = case_size / 2 

	$Panel.add_theme_stylebox_override("panel", StyleBoxFlat.new()) 
	$Panel.get_theme_stylebox("panel").border_width_left = border_size 
	$Panel.get_theme_stylebox("panel").border_width_top = border_size
	$Panel.get_theme_stylebox("panel").border_width_right = border_size
	$Panel.get_theme_stylebox("panel").border_width_bottom = border_size
	$Panel.get_theme_stylebox("panel").border_color = Color.TRANSPARENT 
	$Panel.get_theme_stylebox("panel").bg_color = Color.TRANSPARENT

func _on_case_mouse_entered():
	$Panel.get_theme_stylebox("panel").border_color = Color.FLORAL_WHITE 

func _on_case_mouse_exited():
	$Panel.get_theme_stylebox("panel").border_color = Color.TRANSPARENT 
	
