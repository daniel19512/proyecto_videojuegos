shader_type spatial;
varying vec3 mundo;
uniform vec4 segmentos[64];
uniform float anchuras[64];
uniform int cantidad_segmentos = 0;
uniform vec4 patios[12];
uniform int cantidad_patios = 0;
void vertex(){ mundo=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz; }
float ruido(vec2 p){
 return .5+.24*sin(p.x*.71+sin(p.y*.83))+.23*sin(p.y*.67+sin(p.x*.43));
}
void fragment(){
 float n=ruido(mundo.xz*.47);
 vec3 verde=mix(vec3(.20,.30,.105),vec3(.36,.43,.19),ruido(mundo.xz*.11));
 vec3 tierra=mix(vec3(.29,.205,.12),vec3(.46,.34,.205),n);
 float camino=0.0;
 for(int i=0;i<cantidad_segmentos;i++){
  vec2 a=segmentos[i].xy, b=segmentos[i].zw;
  vec2 d=b-a;
  float distancia=length(mundo.xz-a-d*clamp(dot(mundo.xz-a,d)/max(dot(d,d),.0001),0.0,1.0));
  camino=max(camino,1.0-smoothstep(anchuras[i]*.5-.3,anchuras[i]*.5+.65,distancia+(n-.5)*.35));
 }
 for(int i=0;i<cantidad_patios;i++){
  vec2 centro=(patios[i].xy+patios[i].zw)*.5;
  vec2 mitad=(patios[i].zw-patios[i].xy)*.5;
  vec2 q=abs(mundo.xz-centro)-mitad;
  float distancia=length(max(q,vec2(0)))+min(max(q.x,q.y),0.0);
  camino=max(camino,1.0-smoothstep(-.15,.7,distancia+(n-.5)*.3));
 }
 ALBEDO=mix(verde,tierra,camino)*( .96+.08*ruido(mundo.xz*3.0));
 ROUGHNESS=.97;
}
