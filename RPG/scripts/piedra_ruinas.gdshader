shader_type spatial;
uniform vec4 color_piedra : source_color = vec4(0.47,0.48,0.43,1.0);
varying vec3 mundo;
void vertex() { mundo = (MODEL_MATRIX*vec4(VERTEX,1.0)).xyz; }
void fragment() {
	float veta = sin(mundo.x*3.2+sin(mundo.z*4.0))*sin(mundo.z*2.7+mundo.y*3.8);
	float humedad = smoothstep(0.25,0.7,sin(mundo.x*1.8+mundo.z*2.3)*0.5+0.5)*(1.0-smoothstep(0.1,1.7,mundo.y));
	ALBEDO = mix(color_piedra.rgb*(0.94+veta*0.06),vec3(0.23,0.31,0.15),humedad*0.55);
	ROUGHNESS = 0.97;
}
