shader_type canvas_item;

void fragment() {
	vec4 input_color = texture(TEXTURE, UV);
	COLOR = vec4(0, 0, 0, input_color.a) / 2.0;
}
