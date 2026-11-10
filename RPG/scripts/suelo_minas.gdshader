shader_type spatial;
varying vec3 mundo;
void vertex(){mundo=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz;}
void fragment(){
 vec2 celda=floor(mundo.xz*2.4);
 float grano=fract(sin(dot(celda,vec2(12.9898,78.233)))*43758.5453);
 float mancha=sin(mundo.x*0.7+sin(mundo.z*0.35))*cos(mundo.z*0.8);
 ALBEDO=mix(vec3(0.20,0.21,0.22),vec3(0.32,0.28,0.23),0.5+mancha*0.25)*(0.92+grano*0.16);
 float humedad=smoothstep(0.55,0.9,sin(mundo.x*0.4+cos(mundo.z*0.3)))*step(mundo.z,-52.0);
 ALBEDO*=1.0-humedad*0.18;
 ROUGHNESS=0.97-humedad*0.35;
}
