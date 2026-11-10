shader_type spatial;
render_mode cull_back;
varying vec3 mundo;

void vertex() {
	mundo = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

float ruido(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f*f*(3.0-2.0*f);
	vec4 v = fract(sin(vec4(dot(i,vec2(127.1,311.7)),dot(i+vec2(1,0),vec2(127.1,311.7)),dot(i+vec2(0,1),vec2(127.1,311.7)),dot(i+vec2(1,1),vec2(127.1,311.7))))*43758.5453);
	return mix(mix(v.x,v.y,f.x),mix(v.z,v.w,f.x),f.y);
}

float tramo(vec2 p, vec2 a, vec2 b) {
	return length(p-a-(b-a)*clamp(dot(p-a,b-a)/dot(b-a,b-a),0.0,1.0));
}

void fragment() {
	vec2 p = mundo.xz;
	float d = min(tramo(p,vec2(0,36),vec2(0,24)),tramo(p,vec2(0,24),vec2(-7,13)));
	d = min(d,tramo(p,vec2(-7,13),vec2(0,0)));
	d = min(d,tramo(p,vec2(0,0),vec2(0,-24)));
	d = min(d,tramo(p,vec2(0,0),vec2(23,2)));
	d = min(d,tramo(p,vec2(-7,13),vec2(-17,9)));
	float n = ruido(p*0.7);
	float camino = 1.0-smoothstep(1.75,2.8,d+(n-0.5)*0.9);
	vec3 pasto = mix(vec3(0.21,0.30,0.145),vec3(0.30,0.38,0.20),ruido(p*0.23));
	vec3 tierra = mix(vec3(0.29,0.25,0.17),vec3(0.40,0.34,0.235),n);
	ALBEDO = mix(pasto,tierra,camino);
	ROUGHNESS = 0.96;
}
