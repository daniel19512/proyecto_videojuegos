shader_type spatial;
render_mode cull_back;
uniform vec4 profundo : source_color = vec4(0.075,0.26,0.25,1.0);
uniform vec4 suave : source_color = vec4(0.18,0.43,0.38,1.0);
uniform float tiempo = -1.0;
varying vec3 mundo;
void vertex() {
	mundo = (MODEL_MATRIX*vec4(VERTEX,1.0)).xyz;
}
void fragment() {
	float t = tiempo < 0.0 ? TIME : tiempo;
	float onda = sin(mundo.x*1.6+mundo.z*0.8+t*0.45)*0.5+sin(mundo.z*2.3-mundo.x*0.45-t*0.32)*0.25;
	float manchas = sin(mundo.x*0.4+mundo.z*0.31)*0.5+0.5;
	ALBEDO = mix(profundo.rgb,suave.rgb,0.35+manchas*0.35+onda*0.07);
	float brillo = pow(max(0.0,sin(mundo.x*3.8+mundo.z*1.4+sin(mundo.z*2.1+mundo.x*0.73)*0.9+t*0.40)),20.0);
	brillo *= smoothstep(0.4,0.85,sin(mundo.z*2.7-mundo.x*0.6+t*0.18)*0.5+0.5);
	ALBEDO += vec3(0.015,0.025,0.02)*brillo;
	NORMAL_MAP = vec3(0.5+cos(mundo.x*1.6+mundo.z*0.8+t*0.45)*0.025,0.5+cos(mundo.z*2.3-t*0.32)*0.025,1.0);
	ROUGHNESS = 0.33+onda*0.025;
	SPECULAR = 0.38;
	METALLIC = 0.0;
}
