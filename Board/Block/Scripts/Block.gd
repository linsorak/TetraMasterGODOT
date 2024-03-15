extends Area2D
class_name Block

var textures = [
	"res://Board/Block/Sprites/blockA.png",
	"res://Board/Block/Sprites/blockB.png"
]

func _ready():
	var random_index = randi() % textures.size()
	var texture = load(textures[random_index])
	$Sprite2D.texture = texture

func rescale(case_size: Vector2) -> void:
	var scale_x = case_size.x / $Sprite2D.texture.get_width()
	var scale_y = case_size.y / $Sprite2D.texture.get_height()
	$Sprite2D.scale.x = scale_x
	$Sprite2D.scale.y = scale_y
	print(scale_x)
