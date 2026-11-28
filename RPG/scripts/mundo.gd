extends Node3D


func _ready() -> void:
    var rotulo := get_node_or_null("CartelCasa/Rotulo") as Label3D
    if rotulo:
        rotulo.text = "Casa de %s" % EstadoMundo.nombre_protagonista()
        var fuente := rotulo.font if rotulo.font else ThemeDB.fallback_font
        var ancho := fuente.get_string_size(rotulo.text, HORIZONTAL_ALIGNMENT_LEFT, -1, rotulo.font_size).x
        rotulo.pixel_size = minf(rotulo.pixel_size, 1.82 / maxf(ancho, 1.0))
        var reverso: Label3D = $CartelCasa/Reverso
        reverso.text = rotulo.text
        reverso.pixel_size = rotulo.pixel_size
    print("¡Bienvenido a SapientIA!")

    print("Hola, jugador.")
