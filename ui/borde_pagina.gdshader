shader_type canvas_item;

// El pergamino cálido cubre las pestañas; el lomo azul queda transparente.
void fragment() {
	vec4 papel = texture(TEXTURE, UV);
	float hoja = step(0.46, papel.r) * step(0.0, papel.r - papel.g);
	COLOR = vec4(papel.rgb, papel.a * hoja);
}
