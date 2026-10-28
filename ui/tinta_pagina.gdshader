shader_type canvas_item;

// Conserva la tinta y deja que el pergamino común se vea debajo.
void fragment() {
	vec4 dibujo = texture(TEXTURE, UV);
	float tinta = 1.0 - smoothstep(0.58, 0.76, dibujo.g);
	COLOR = vec4(dibujo.rgb, dibujo.a * tinta);
}
