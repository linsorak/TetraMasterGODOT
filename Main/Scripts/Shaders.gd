extends Node
class_name Shaders

func apply_color_shader(sprite: Sprite2D, shader: Shader) -> void:
	sprite.shader = shader

func remove_color_shader(sprite: Sprite2D) -> void:
	sprite.shader = null

func load_shader(name: String) -> Shader:
	match name:
		"masking":
			var black_shader = load("res://Main/Shaders/masking.gdshader")
			
