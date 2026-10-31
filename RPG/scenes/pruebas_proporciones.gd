extends Node3D
## Control visual exclusivo de esta muestra; no cambia recursos ni al protagonista.


func _on_originales_toggled(originales: bool) -> void:
	for edificio: Node3D in $Edificios.get_children():
		var factor: float = 1.0 if originales else float(edificio.get_meta("escala_cubierta_propuesta"))
		edificio.get_node("Cubierta").scale = Vector3(1, factor, 1)
		var cuerpo: Vector2 = edificio.get_meta("cuerpo")
		edificio.get_node("Rotulo").text = "%d x %d  |  cubierta Y %.2f" % [cuerpo.x, cuerpo.y, factor]
