shader_type spatial;
render_mode cull_disabled;

// Velocidades en unidades del mundo por segundo; ambas capas avanzan hacia +Z.
uniform float velocidad_corriente : hint_range(0.05, 2.0, 0.05) = 0.65;
uniform float intensidad_ondas : hint_range(0.0, 1.0, 0.01) = 0.55;
uniform float intensidad_reflejos : hint_range(0.0, 1.0, 0.01) = 0.24;
uniform vec4 color_base : source_color = vec4(0.13, 0.31, 0.29, 1.0);
uniform vec4 color_claro : source_color = vec4(0.42, 0.61, 0.54, 1.0);
varying vec3 posicion;

void vertex() {
	posicion = VERTEX;
}

void fragment() {
	float flujo = posicion.z - TIME * velocidad_corriente;
	float flujo_lento = posicion.z - TIME * velocidad_corriente * 0.72;
	float ondulacion = sin(posicion.x * 3.2) * 0.48 + sin(posicion.x * 7.3) * 0.12;
	float onda = sin(flujo * 3.6 + ondulacion + sin(posicion.x * 0.83 + flujo * 0.34) * 1.3);
	float secundaria = sin(flujo_lento * 6.8 - posicion.x * 1.9);
	// Crestas cortas, repartidas en el ancho; no forman franjas blancas completas.
	float cresta = smoothstep(0.86, 0.995, onda);
	float segmentos = smoothstep(-0.2, 0.8, sin(posicion.x * 7.1 + sin(flujo * 1.1 + posicion.x * 1.7) * 2.4 + sin(flujo * 0.47) * 1.2));
	float lineas = cresta * segmentos;
	float fondo = sin(posicion.x * 2.1 + posicion.z * 0.36) * 0.5 + 0.5;
	float tono = 0.04 + fondo * 0.10 + intensidad_ondas * (0.055 * onda + 0.035 * secundaria);
	// Agitacion localizada en el contacto de la rueda (coordenadas locales del rio).
	float contacto = 1.0 - smoothstep(0.35, 1.3, length((posicion.xz - vec2(26.5, -10.0)) * vec2(1.7, 0.8)));
	float agitada = contacto * smoothstep(0.35, 0.95, secundaria * onda);
	ALBEDO = mix(color_base.rgb, color_claro.rgb, clamp(tono + intensidad_reflejos * (lineas + agitada * 0.5), 0.0, 0.65));
	ROUGHNESS = 0.78 - intensidad_reflejos * 0.12 * lineas;
	SPECULAR = 0.18 + intensidad_reflejos * 0.1;
	NORMAL_MAP = vec3(0.5 + 0.035 * intensidad_ondas * onda, 0.5 + 0.025 * intensidad_ondas * secundaria, 1.0);
}
