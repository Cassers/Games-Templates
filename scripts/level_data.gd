extends Resource
class_name LevelData
## LevelData: un nivel es DATOS, no código. ¡El archivo estrella de este género!
##
## Cada nivel del juego es un archivo .tres (ver niveles/level_01.tres): un
## paquete de DATOS que dice dónde está el jugador, dónde está la meta y qué
## plataformas existen. Los datos NO saben dibujarse ni tener colisión: de
## eso se encarga LevelBuilder, que usa ESTE script como receta.
##
## ¿Por qué es la mejor manera de hacer level design?
##  - Se edita desde el INSPECTOR (no hay que tocar código para crear niveles).
##  - Un nivel nuevo = duplicar un .tres, rellenarlo y añadirlo a la lista
##    `levels` del LevelStore. CERO código.
##  - Es trabajo en equipo por naturaleza: un artista o diseñador puede crear
##    niveles sin depender de quien escribe los scripts.
##
## Nota (patrón de la plantilla): combinamos `class_name LevelData` (para el
## editor) con `ext_resource` por ruta en los .tres, para que todo funcione
## a la primera desde consola (CLI), sin caché de clases del editor.

# Nombre del nivel (se muestra en el HUD).
@export var level_name: String = "Nivel sin nombre"

# Dónde aparece el jugador al empezar (posición del nodo Player).
@export var player_spawn: Vector2 = Vector2(64, 536)

# Dónde se dibuja la meta (área verde). Ponla sobre la última plataforma.
@export var goal_position: Vector2 = Vector2(1000, 200)

# Plataformas: cada una es UN Dictionary con su posición (CENTRO) y su tamaño.
#   {"position": Vector2(x, y), "size": Vector2(ancho, alto)}
#
# Ejemplo: {"position": Vector2(300, 400), "size": Vector2(200, 40)}
#   → una plataforma de 200×40 px, centrada en (300, 400), es decir que
#     ocupa x ∈ [200, 400] e y ∈ [380, 420].
#
# Coordenadas Godot 2D: +X = hacia la DERECHA, +Y = hacia ABAJO (el eje Y
# crece hacia abajo). Un y pequeño = más arriba en pantalla.
#
# En el inspector, cada entrada se edita como una fila de la lista
# "Platforms": posición y tamaño, sin escribir una sola línea de código.
@export var platforms: Array[Dictionary] = []