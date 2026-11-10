shader_type spatial;
render_mode cull_disabled;
varying vec3 local;
void vertex() { local = VERTEX; }
void fragment() {
 float flujo = local.z - TIME * 1.4 - TIME * max(0.0, -NORMAL.y) * 2.0;
 float onda = sin(flujo * 4.5 + sin(local.x * 2.7));
 float cresta = smoothstep(.76, .99, onda) * (.35 + .3 * sin(local.x * 6.0 + flujo));
 ALBEDO = mix(vec3(.055,.30,.34),vec3(.63,.85,.81), .13 + cresta * .48);
 ROUGHNESS = .72;
 SPECULAR = .24;
}
