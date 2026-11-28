extends RefCounted

## Escala lógica histórica de los guardados y los sistemas del mundo.
const UNIDADES_DIA := 720.0

static func minutos_del_dia(hora_logica: float) -> int:
	return posmod(floori(hora_logica * 1440.0 / UNIDADES_DIA) + 360, 1440)
