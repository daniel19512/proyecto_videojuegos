shader_type spatial;
render_mode cull_back;
uniform sampler2D mascara : filter_linear_mipmap, repeat_disable;
uniform vec4 hierba_oscura : source_color = vec4(0.30, 0.36, 0.20, 1.0);
uniform vec4 hierba_clara : source_color = vec4(0.37, 0.42, 0.24, 1.0);
uniform vec4 tierra : source_color = vec4(0.51, 0.39, 0.25, 1.0);
uniform vec4 hierba_seca : source_color = vec4(0.43, 0.42, 0.26, 1.0);
uniform vec4 plaza : source_color = vec4(0.55, 0.47, 0.34, 1.0);
uniform float irregularidad : hint_range(0.0, 0.35) = 0.25;
varying vec3 mundo;
float hash(vec2 p) {
	vec3 q=fract(vec3(p.xyx)*0.1031);
	q+=dot(q,q.yzx+33.33);
	return fract((q.x+q.y)*q.z);
}
float ruido(vec2 p) {
	vec2 i=floor(p), f=fract(p); f=f*f*(3.0-2.0*f);
	return mix(mix(hash(i),hash(i+vec2(1,0)),f.x),mix(hash(i+vec2(0,1)),hash(i+vec2(1,1)),f.x),f.y);
}
void vertex() { mundo=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz; }
void fragment() {
	vec2 p=mundo.xz;
	vec2 mascara_suelo=texture(mascara,(p+vec2(40,36))/vec2(80,72)).rg;
	float grande=ruido(p*0.18);
	float medio=ruido(p*0.75);
	float fino=ruido(p*5.0);
	float borde=(medio-0.5)*irregularidad+(ruido(p*2.1)-0.5)*0.045;
	float camino=smoothstep(0.29,0.65,mascara_suelo.r+borde);
	float explanada=smoothstep(0.29,0.68,mascara_suelo.g+borde*0.65);
	vec3 verde=mix(hierba_oscura.rgb,hierba_clara.rgb,grande*0.7+medio*0.3);
	float seco=smoothstep(0.61,0.85,grande)*0.32;
	verde=mix(verde,hierba_seca.rgb,seco);
	vec3 suelo=tierra.rgb*(0.93+grande*0.10+medio*0.06+(fino-0.5)*0.065);
	vec3 centro=plaza.rgb*(0.94+medio*0.09+(fino-0.5)*0.045);
	ALBEDO=mix(mix(verde,suelo,camino),centro,explanada);
	ROUGHNESS=0.95;
	SPECULAR=0.12;
}
