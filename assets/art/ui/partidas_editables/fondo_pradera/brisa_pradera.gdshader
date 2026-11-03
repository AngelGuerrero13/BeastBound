shader_type canvas_item;

uniform float brisa : hint_range(0.0, 2.0) = 1.0;
uniform float corriente : hint_range(0.0, 2.0) = 1.0;

float verdor(vec3 c) {
	return smoothstep(0.025, 0.11, c.g - max(c.r, c.b));
}

void fragment() {
	// Distancias en píxeles del lienzo de juego (640 x 360).
	vec2 pixel = vec2(1.0 / 640.0, 1.0 / 360.0);
	vec2 p = UV / pixel;
	vec3 base = texture(TEXTURE, UV).rgb;
	float verde = verdor(base);
	// Incluye los pétalos y centros claros rodeados de vegetación.
	float cerca = max(verdor(texture(TEXTURE, UV + vec2(0.0, 5.0) * pixel).rgb),
		verdor(texture(TEXTURE, UV - vec2(5.0, 0.0) * pixel).rgb));
	float flor = smoothstep(0.75, 0.94, min(base.r, base.g)) * cerca;
	float rafaga = sin(TIME * 1.55 - p.x * 0.024 + p.y * 0.018);
	float detalle = sin(TIME * 2.25 + p.y * 0.105 - p.x * 0.038);
	float hojas = 1.0 - smoothstep(0.35, 0.78, base.g);
	float amplitud = max(verde * mix(0.68, 1.35, hojas), flor * 1.15);
	vec2 viento = vec2(rafaga + detalle * 0.30, detalle * 0.28) * amplitud * brisa;

	float agua = smoothstep(0.12, 0.33, min(base.g, base.b) - base.r);
	float ola = sin(p.y * 0.32 - TIME * 1.65 + sin(p.x * 0.06));
	vec2 flujo = vec2(1.30 * ola, 0.44 * sin(p.x * 0.10 - TIME)) * agua * corriente;
	vec2 muestra = clamp(UV + (viento + flujo) * pixel, TEXTURE_PIXEL_SIZE * 0.5, vec2(1.0) - TEXTURE_PIXEL_SIZE * 0.5);
	vec4 paisaje = texture(TEXTURE, muestra);
	// La costa entra por la esquina superior derecha. Muestrear hacia el
	// mar trae el agua y su espuma sobre la orilla durante la cresta.
	if (UV.x > 0.87 && UV.y < 0.29) {
		float ciclo = 0.5 - 0.5 * cos(TIME * 1.85 + p.y * 0.035);
		vec2 normal_mar = vec2(0.88, -0.48);
		float alcance = ciclo * (11.5 + 1.5 * sin(p.y * 0.15));
		vec2 origen = clamp(UV + normal_mar * alcance * pixel, TEXTURE_PIXEL_SIZE * 0.5, vec2(1.0) - TEXTURE_PIXEL_SIZE * 0.5);
		vec2 tangente = vec2(-normal_mar.y, normal_mar.x);
		float remolino = sin(TIME * 1.4 - dot(p, tangente) * 0.18);
		vec2 uv_reflejo = origen + pixel * corriente * (tangente * remolino + normal_mar * ola * (0.55 + ciclo));
		vec3 ola_orilla = texture(TEXTURE, origen).rgb;
		vec3 reflejo = texture(TEXTURE, clamp(uv_reflejo, vec2(0.0), vec2(1.0))).rgb;
		float celeste = smoothstep(0.16, 0.38, min(ola_orilla.g, ola_orilla.b) - ola_orilla.r);
		float reflejo_agua = smoothstep(0.12, 0.32, min(reflejo.g, reflejo.b) - reflejo.r);
		ola_orilla = mix(ola_orilla, reflejo, celeste * reflejo_agua);
		vec3 mar_cercano = texture(TEXTURE, clamp(origen + normal_mar * 4.0 * pixel, vec2(0.0), vec2(1.0))).rgb;
		float espuma = smoothstep(0.84, 0.95, min(ola_orilla.r, min(ola_orilla.g, ola_orilla.b)));
		float mojado = smoothstep(0.14, 0.35, min(ola_orilla.g, ola_orilla.b) - ola_orilla.r);
		float costa = smoothstep(0.12, 0.32, min(mar_cercano.g, mar_cercano.b) - mar_cercano.r);
		paisaje.rgb = mix(paisaje.rgb, ola_orilla, max(mojado, espuma * costa) * smoothstep(0.0, 0.7, alcance));
		// Los brillos recorren el agua somera incluso al cambiar de sentido la marea.
		float somera = smoothstep(0.16, 0.40, min(paisaje.g, paisaje.b) - paisaje.r)
			* smoothstep(0.67, 0.94, paisaje.g);
		vec2 celda = floor(origen / pixel);
		float cresta = sin(dot(celda, normal_mar) * 0.38 + TIME * 2.1 + 0.7 * remolino);
		float brillo = smoothstep(0.52 - 0.24 * ciclo, 0.88, cresta);
		paisaje.rgb = mix(paisaje.rgb, vec3(0.66, 0.98, 1.0), somera * brillo * (0.17 + 0.17 * ciclo));
	}
	COLOR = paisaje;
}
