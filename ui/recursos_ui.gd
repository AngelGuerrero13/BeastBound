extends RefCounted

const HOJA := preload("res://assets/art/ui/Sprout Lands - UI Pack - Basic pack/Sprite sheets/Sprite sheet for Basic Pack.png")
const FRAMES := {
	"Jugar": [Rect2(160, 208, 96, 32), Rect2(256, 208, 96, 32)],
	"Configuracion": [Rect2(640, 64, 32, 32), Rect2(672, 64, 32, 32)],
	"Controles": [Rect2(640, 96, 32, 32), Rect2(672, 96, 32, 32)],
	"Creditos": [Rect2(832, 32, 32, 32), Rect2(864, 32, 32, 32)],
	"Salir": [Rect2(832, 0, 32, 32), Rect2(864, 0, 32, 32)],
	"inicio": [Rect2(768, 64, 32, 32), Rect2(800, 64, 32, 32)],
}
const ICONOS := {
	"Configuracion": Rect2(656, 192, 16, 16),
	"Controles": Rect2(608, 192, 16, 16),
	"Creditos": Rect2(688, 192, 16, 16),
	"Salir": Rect2(672, 224, 16, 16),
	"inicio": Rect2(640, 224, 16, 16),
	"volver": Rect2(672, 224, 16, 16),
}


static func recortar(region: Rect2) -> AtlasTexture:
	var textura := AtlasTexture.new()
	textura.atlas = HOJA
	textura.region = region
	textura.filter_clip = true
	return textura


static func frame(nombre: String, presionado: bool = false) -> AtlasTexture:
	return recortar(FRAMES[nombre][1 if presionado else 0])


static func icono(nombre: String) -> AtlasTexture:
	return recortar(ICONOS.get(nombre, Rect2(672, 224, 16, 16)))
