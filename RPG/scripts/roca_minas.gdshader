shader_type spatial;
render_mode cull_disabled;
uniform vec4 color_roca : source_color = vec4(0.23,0.26,0.28,1.0);
uniform vec3 jugador = vec3(0.0);
uniform vec3 camara = vec3(0.0);
uniform bool es_techo = false;
varying vec3 mundo;
void vertex(){ mundo = (MODEL_MATRIX * vec4(VERTEX,1.0)).xyz; }
void fragment(){
 vec3 objetivo = jugador + vec3(0.0,0.8,0.0);
 vec3 linea = camara-objetivo;
 float t = dot(mundo-objetivo,linea)/max(dot(linea,linea),0.01);
 float distancia = length(mundo-(objetivo+linea*clamp(t,0.0,1.0)));
 if(es_techo && length(mundo.xz-jugador.xz)<32.0) discard;
 // Ventana amplia de lectura alrededor del protagonista en cualquier órbita.
 if(t > -0.03 && t < 1.08 && distancia < 6.0 && mundo.y > jugador.y+0.3) discard;
 float veta = sin(mundo.x*1.7+mundo.y*2.1+sin(mundo.z*0.8));
 ALBEDO = color_roca.rgb*(0.88+0.12*veta);
 ROUGHNESS = 0.92;
}
