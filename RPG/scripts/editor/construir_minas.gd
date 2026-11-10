extends "res://scripts/editor/minas_geometria.gd"
# Autoría por zonas; la geometría y utilidades están en minas_geometria.gd.
func decoracion() -> void:
	var entrada := grupo(mapa,"ZonaA_Entrada")
	var galeria := grupo(mapa,"ZonaB_Galeria")
	var extraccion := grupo(mapa,"ZonaC_Extraccion")
	var profunda := grupo(mapa,"ZonaD_Profunda")
	var caverna := grupo(mapa,"ZonaE_Caverna")
	var depositos := grupo(mapa,"ZonaF_Depositos")
	var grava := SphereMesh.new()
	grava.radial_segments = 5
	grava.rings = 2
	grava.radius = .22
	grava.height = .25
	for i in 90:
		var p := Vector2(rng.randf_range(-30,28),rng.randf_range(-96,9))
		if not dentro(p) or estanque(p)<1.2: continue
		var n := MeshInstance3D.new()
		n.mesh = grava
		n.material_override = metal
		n.position = punto(p)
		n.scale = Vector3.ONE*rng.randf_range(.4,1.2)
		galeria.add_child(n)
	for par in [[Vector2(17,-46),2.0],[Vector2(-2,-45),1.5],[Vector2(25,-81),3.0],[Vector2(-7,-91),2.5]]:
		modelo(extraccion,"Rock_Medium_1",punto(par[0]),par[1],true,"res://assets/naturaleza/glTF/")
	for z in [4,-6,-16]: soporte(entrada,punto(Vector2(0,z)),6.0)
	for p in [Vector2(-5,-23),Vector2(0,-32),Vector2(8,-47)]: soporte(galeria,punto(p),6)
	for p in [Vector2(-6,-59),Vector2(-5,-70),Vector2(-22,-67)]: soporte(profunda,punto(p),4.4,true)
	for par in [[Vector2(0,4),Vector2(0,-10)],[Vector2(-6,-22),Vector2(0,-32)],[Vector2(8,-34),Vector2(8,-45)],[Vector2(-21,-67),Vector2(-24,-70)]]:
		rail(galeria,punto(par[0]),punto(par[1]))
	vagoneta(extraccion,Vector3(8,-4,-44))
	vagoneta(depositos,Vector3(-25,-4,-38))
	for p in [Vector2(-4,1),Vector2(4,-6),Vector2(-8,-22),Vector2(3,-32),Vector2(16,-39),Vector2(-21,-34),Vector2(-9,-59),Vector2(-23,-70),Vector2(-3,-78),Vector2(2,-90)]:
		luz(entrada,punto(p)+Vector3.UP*2.7)
	for p in [Vector2(20,-79),Vector2(11,-93)]: luz(caverna,punto(p)+Vector3.UP*3,true)
	for par in [["Barrel",Vector2(-4,4)],["Crate_Wooden",Vector2(4,-2)],["Bag",Vector2(-25,-34)],["Barrel",Vector2(-27,-37)],["Crate_Wooden",Vector2(-22,-42)],["Crate_Wooden",Vector2(-23,-42)],["Barrel",Vector2(17,-37)]]:
		modelo(depositos,par[0],punto(par[1]),.9,true)
	modelo(entrada,"Pickaxe_Bronze",Vector3(4,0,-3),1.2)
	modelo(extraccion,"Pickaxe_Bronze",Vector3(17,-4,-41),1.1)
	for pos in [Vector3(16.8,-4,-38),Vector3(-24,-4,-42)]:
		viga(depositos,pos+Vector3.UP*.25,pos+Vector3(.25,1.5,0),.06,tablas)
		caja(depositos,"PalaDecorativa",pos+Vector3.UP*.18,Vector3(.3,.36,.06),metal)
	# Antiguo pescante de carga sobre la plataforma; sin interacción ni física móvil.
	viga(caverna,Vector3(1,-12,-89),Vector3(1,-8.5,-89),.22,madera,true)
	viga(caverna,Vector3(1,-8.5,-89),Vector3(4,-8.5,-89),.20,tablas)
	viga(caverna,Vector3(1,-10,-89),Vector3(3,-8.5,-89),.15,madera)
	viga(caverna,Vector3(4,-8.5,-89),Vector3(4,-10.6,-89),.035,madera)
	for i in 6: caja(depositos,"MaderaApilada",Vector3(-27,-3.8+i*.18,-41),Vector3(2.4,.16,.25),tablas)
	var cobre := material(Color(.42,.26,.16))
	var gris := material(Color(.43,.47,.49))
	var azul := material(Color(.16,.33,.38))
	azul.emission_enabled = true
	azul.emission = Color(.025,.10,.12)
	var veta_roca := material(Color(.24,.27,.29))
	macizo(extraccion,"FrenteMineral",Vector3(19.3,-2.3,-40.5),Vector3(3,3.4,8.5),veta_roca)
	macizo(profunda,"FilonFinal",Vector3(-28.6,-10.3,-73.5),Vector3(1.7,2.2,4.0),veta_roca)
	macizo(caverna,"CrestaCristalina",Vector3(24,-10,-90),Vector3(4,4,5.5),veta_roca)
	for i in 30:
		var y := -3.0+float(i%4)*.5
		var z := -43+float(i/4)*.8
		var cara := 19.3-1.5*sqrt(maxf(.1,1-pow((y+2.3)/1.7,2)-pow((z+40.5)/4.25,2)))
		var pos := Vector3(cara+.08,y,z)
		cristal(extraccion,pos,rng.randf_range(.35,.8),[cobre,gris,azul][i%3])
	for i in 14: cristal(profunda,Vector3(-28+sin(i)*.6,-10+float(i%3)*.4,-75+float(i/3)*.5),.5,cobre)
	for i in 18: cristal(caverna,Vector3(22.05+sin(i)*.12,-10+float(i%4)*.65,-91+float(i/4)*.7),.9,azul)
	for p in [Vector2(-8,-85),Vector2(24,-76),Vector2(17,-94)]:
		var pos := punto(p)
		cristal(caverna,pos+Vector3.UP*2.0,4.0,roca)
		var n := caja(caverna,"ColumnaNatural",pos+Vector3.UP*4,Vector3(1.8,8,1.8),roca,true)
		n.rotation.y = .4
	for i in 15:
		var pos := Vector3(-9+rng.randf()*32,-2,-75-rng.randf()*19)
		cristal(caverna,pos,2.5,roca)
		caverna.get_child(caverna.get_child_count()-1).rotation.z = PI
	# Final del ramal abandonado: derrumbe sÃ³lido, filÃ³n integrado detrÃ¡s.
	for i in 4: caja(profunda,"Derrumbe",punto(Vector2(-28+i,-76))+Vector3.UP*.6,Vector3(1.2,1.2,1.1),roca,true)
	var cartel := Label3D.new()
	cartel.text = "MONTAÃ‘AS  â†‘"
	cartel.position = Vector3(3.4,2.4,6.8)
	cartel.font_size = 32
	cartel.pixel_size = .012
	cartel.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	entrada.add_child(cartel)
	caja(entrada,"TablillaSalida",Vector3(3.4,1.8,7),Vector3(2.7,.7,.15),madera)
	caja(entrada,"PosteCartel",Vector3(3.4,.8,7),Vector3(.18,1.6,.18),madera,true)

func agua() -> void:
	var g := grupo(mapa,"AguaYOrillas")
	var mat := ShaderMaterial.new()
	mat.shader = load("res://scripts/agua_minas.gdshader")
	var vertices := PackedVector3Array()
	for i in 32:
		var a := TAU*i/32.0
		var b := TAU*(i+1)/32.0
		vertices.append_array(PackedVector3Array([Vector3(16,-13.1,-84),Vector3(16+cos(a)*5.5,-13.1,-84+sin(a)*4.5),Vector3(16+cos(b)*5.5,-13.1,-84+sin(b)*4.5)]))
	superficie(g,"Estanque",vertices,mat,false)
	for i in 32:
		var a := TAU*i/32.0
		var b := TAU*(i+1)/32.0
		var pa := Vector3(16+cos(a)*7,-12,-84+sin(a)*6)
		var pb := Vector3(16+cos(b)*7,-12,-84+sin(b)*6)
		viga(g,pa+Vector3.UP*.7,pb+Vector3.UP*.7,.22,madera,true)
		caja(g,"Orilla",(pa+pb)*.5-Vector3.UP*.25,Vector3(1.5,1.1,1.4),roca,true)
	# Pasarela y plataforma sobre orilla oeste, sin acceso al agua profunda.
	for i in 16: caja(g,"Tablon",Vector3(7,-12.06,-78-i*.55),Vector3(3,.12,.50),tablas,true)
	for x in [5.5,8.5]: viga(g,Vector3(x,-11,-78),Vector3(x,-11,-86.5),.14,madera,true)
	caja(g,"Plataforma",Vector3(3,-12.06,-87),Vector3(5,.12,4),tablas,true)

func propietarios(n: Node) -> void:
	for hijo in n.get_children():
		hijo.owner = mapa
		if hijo.scene_file_path.is_empty(): propietarios(hijo)

func construir() -> void:
	rng.seed = 70708
	mapa.name = "Minas"
	root.add_child(mapa)
	roca = ShaderMaterial.new()
	roca.shader = load("res://scripts/roca_minas.gdshader")
	boveda = roca.duplicate()
	boveda.set_shader_parameter("es_techo",true)
	mapa.set_script(load("res://scripts/minas_visibilidad.gd"))
	var superficies: Array[ShaderMaterial] = [roca,boveda]
	mapa.set("superficies",superficies)
	terreno()
	decoracion()
	agua()
	var rutas := grupo(mapa,"Recorridos")
	for i in RUTAS.size():
		var n := grupo(rutas,["Principal","Deposito","Abandonado"][i])
		var eje := PackedVector3Array()
		for p in RUTAS[i]: eje.append(punto(p))
		n.set_meta("eje",eje)
	var marcadores := grupo(mapa,"Marcadores")
	for par in [["EntradaMontanas",Vector3(0,.05,0)],["RetornoMontanas",Vector3(0,0,8)]]:
		var n := Marker3D.new()
		n.name = par[0]
		n.position = par[1]
		n.set_meta("direccion_visual","arriba")
		marcadores.add_child(n)
	propietarios(mapa)
	var packed := PackedScene.new()
	var error := packed.pack(mapa)
	if error == OK: error = ResourceSaver.save(packed,"res://scenes/minas.tscn")
	print("MINAS_AUTORIA: ",error," celdas=",celdas.size())
	quit(error)



