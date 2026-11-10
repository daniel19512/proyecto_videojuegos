shader_type spatial;
render_mode cull_back;
varying vec3 mundo;
uniform vec4 color_hierba : source_color = vec4(0.32,0.43,0.21,1.0);
uniform vec4 color_tierra : source_color = vec4(0.49,0.37,0.23,1.0);
uniform vec4 color_reserva : source_color = vec4(0.35,0.39,0.35,1.0);
float hash(vec2 p) { return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453); }
float ruido(vec2 p) {
	vec2 i=floor(p); vec2 f=fract(p); f=f*f*(3.0-2.0*f);
	return mix(mix(hash(i),hash(i+vec2(1,0)),f.x),mix(hash(i+vec2(0,1)),hash(i+vec2(1,1)),f.x),f.y);
}
// Depresión exclusivamente visual dentro de la reserva físicamente inaccesible.
// La malla/colisión original y todas las superficies transitables se conservan.
uniform bool laguna_activa = true;
float radio_laguna(vec2 p) {
	vec2 q = (p-vec2(-29.0,22.0))/vec2(8.0,6.0);
	float a = atan(q.y,q.x);
	return length(q)/(0.94+0.035*sin(a*3.0+0.4)+0.025*sin(a*5.0-0.7));
}
void vertex() {
	vec3 original = (MODEL_MATRIX * vec4(VERTEX,1.0)).xyz;
	float r = radio_laguna(original.xz);
	if (laguna_activa && r<1.0) {
		VERTEX.y = mix(-0.72,VERTEX.y,smoothstep(0.58,1.0,r));
	}
	mundo = (MODEL_MATRIX * vec4(VERTEX,1.0)).xyz;
}
void fragment() {
	float grano = (ruido(mundo.xz*3.0)-0.5)*0.012;
	float manchas = ruido(mundo.xz*0.16)*0.65+ruido(mundo.xz*0.53)*0.35;
	vec3 hierba = color_hierba.rgb*mix(0.78,1.15,manchas);
	vec3 tierra = color_tierra.rgb*mix(0.88,1.12,manchas);
	float camino = smoothstep(0.05,0.95,COLOR.r+(ruido(mundo.xz*1.4)-0.5)*0.12);
	vec3 base = mix(hierba,tierra,camino);
	// Arcilla seca indica reserva, NO representa agua terminada ni nadable.
	base = mix(base,color_reserva.rgb*mix(0.85,1.1,manchas),smoothstep(0.1,0.65,COLOR.b)*0.95);
		if (laguna_activa) {
		float r = radio_laguna(mundo.xz);
		float ribera = 1.0-smoothstep(1.0,1.13,r);
		vec3 orilla = mix(vec3(0.095,0.13,0.065),vec3(0.17,0.18,0.10),ruido(mundo.xz*1.6));
		base = mix(base,orilla,ribera);
	}
	ALBEDO = base+grano;
	ROUGHNESS = 0.96;
}
