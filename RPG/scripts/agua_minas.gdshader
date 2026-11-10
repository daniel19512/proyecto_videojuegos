shader_type spatial;
uniform vec4 color_agua : source_color = vec4(0.035,0.14,0.16,1.0);
varying vec3 mundo;
void vertex(){ mundo=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz; }
void fragment(){
 float onda=sin(mundo.x*2.2+TIME*0.4)*sin(mundo.z*1.7-TIME*0.3);
 ALBEDO=color_agua.rgb+vec3(0.004,0.01,0.01)*onda;
 EMISSION=vec3(0.004,0.012,0.014);
 ROUGHNESS=0.5;
 NORMAL=normalize(NORMAL+vec3(onda*0.025,0.012*cos(mundo.x+TIME*0.3),0.0));
 METALLIC=0.05;
}
