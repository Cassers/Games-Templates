#!/usr/bin/env bash
# =============================================================================
#  Asistente de creación de proyecto Godot 2D (plantilla de clase)
# =============================================================================
#  Partiendo de esta PLANTILLA genérica, este script genera un proyecto
#  listo para abrir en Godot 4.7, con la escena base de un género
#  (plataformero, top-down, shooter, roguelike o puzzle).
#
#  Uso interactivo:      ./setup.sh
#  Uso no interactivo:   ./setup.sh --genre platformer --name Prueba --dir /tmp/mi_juego
#    (--genre, --name y --dir son OPCIONALES; lo que falte se pregunta)
#
#  Géneros válidos: platformer | topdown | shooter | roguelike | puzzle | generic | leveldesign
# =============================================================================

set -u  # Fallar si se usa una variable sin definir (nos ayuda a cazar typos)

# --- 1) Determinamos de dónde se ejecuta el script ---------------------------
# SOURCE_DIR es la carpeta de ESTA plantilla. La calculamos con su propia
# ruta (no con "pwd") para que el script funcione desde cualquier carpeta.
SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- 2) Leemos los argumentos opcionales (mismo estilo en bash puro) --------
GENRE=""
PROJECT_NAME=""
DEST_DIR=""

while [[ $# -gt 0 ]]; do
	case "$1" in
		--genre)
			GENRE="$2"
			shift 2
			;;
		--name)
			PROJECT_NAME="$2"
			shift 2
			;;
		--dir)
			DEST_DIR="$2"
			shift 2
			;;
		*)
			echo "Error: argumento desconocido: $1" >&2
			exit 1
			;;
	esac
done

# --- 3) Banner + menú interactivo de género ----------------------------------
if [[ -z "$GENRE" ]]; then
	echo ""
	echo "=================================================="
	echo "  Asistente de creación de proyecto Godot 2D"
	echo "  Plantilla para clase — Godot 4.7"
	echo "=================================================="
	echo ""
	echo " ¿Qué tipo de juego quieres crear?"
	echo ""
	echo "   1) Plataformero"
	echo "   2) Top-down"
	echo "   3) Shooter 2D"
	echo "   4) Roguelike"
	echo "   5) Puzzle"
	echo "   6) Genérico (base sin género)"
	echo "   7) Level Design (niveles como datos)"
	echo ""
	read -r -p " Opción [1-7], Enter para genérico: " choice

	# Mapa del número elegido al nombre del género. Genérica/o por defecto.
	case "${choice:-6}" in
		1) GENRE="platformer" ;;
		2) GENRE="topdown" ;;
		3) GENRE="shooter" ;;
		4) GENRE="roguelike" ;;
		5) GENRE="puzzle" ;;
		6|"") GENRE="generic" ;;
		7) GENRE="leveldesign" ;;
		*)
			echo "Error: \"$choice\" no es una opción válida." >&2
			exit 1
			;;
	esac
fi

# --- 4) Nombre del proyecto (con sanitización) --------------------------------
# En ProjectSettings el nombre tolera espacios, pero para la CARPETA y para
# evitar sorpresas de rutas, usamos solo letras, números, guion y guion bajo.
if [[ -z "$PROJECT_NAME" ]]; then
	read -r -p " Nombre del proyecto [MiJuego]: " PROJECT_NAME
fi
PROJECT_NAME="${PROJECT_NAME:-MiJuego}"
# Sed que borra TODO lo que no sea alfanumérico, guion o guion bajo.
PROJECT_NAME="$(printf '%s' "$PROJECT_NAME" | sed 's/[^a-zA-Z0-9_-]//g')"
if [[ -z "$PROJECT_NAME" ]]; then
	echo "Error: el nombre quedó vacío tras la sanitización." >&2
	exit 1
fi

# --- 5) Carpeta de destino ----------------------------------------------------
# Por defecto: la carpeta padre de la plantilla, con el nombre del proyecto.
if [[ -z "$DEST_DIR" ]]; then
	DEST_DIR="$(dirname "$SOURCE_DIR")/$PROJECT_NAME"
fi

# Seguridad: negarse a crear el proyecto DENTRO de la propia plantilla
# (si no, ¡el asistente se copiaría a sí mismo infinitamente y borraría
# su propio setup.sh al limpiar!). Comparamos la ruta canónica del destino
# contra la plantilla y contra cualquier subcarpeta de ella.
DEST_CANON="$(cd "$(dirname "$DEST_DIR")" 2>/dev/null && pwd)/$(basename "$DEST_DIR")"
if [[ "$DEST_CANON" == "$SOURCE_DIR" || "$DEST_CANON" == "$SOURCE_DIR"/* ]]; then
	echo "Error: no se puede crear el proyecto dentro de la propia plantilla." >&2
	exit 1
fi

# --- 6) Copiamos la base (skeleton) -------------------------------------------
# Copiamos TODO el contenido de la plantilla (incluido .editorconfig, .gitignore,
# README y docs/CLASE.md, útiles en clase) y luego borramos lo que NO debe
# viajar: este mismo script, los starters y cualquier .git.
echo "Creando proyecto \"$PROJECT_NAME\" (género: $GENRE) en:"
echo "  $DEST_DIR"
mkdir -p "$DEST_DIR" || { echo "Error: no se pudo crear $DEST_DIR" >&2; exit 1; }
cp -r "$SOURCE_DIR/." "$DEST_DIR/" || { echo "Error: falló la copia de la plantilla." >&2; exit 1; }
rm -rf "$DEST_DIR/setup.sh" "$DEST_DIR/starters" "$DEST_DIR/.git"

# --- 7) Superponemos la escena del género elegido -----------------------------
# Los starters son "capas de género": sobrescriben scenes/ con la versión
# del género. El resto del proyecto (autoload, HUD, config) se mantiene.
if [[ -d "$SOURCE_DIR/starters/$GENRE" ]]; then
	cp -r "$SOURCE_DIR/starters/$GENRE/." "$DEST_DIR/" || { echo "Error: falló la copia del género." >&2; exit 1; }
else
	echo "Error: género desconocido: $GENRE" >&2
	echo "Géneros válidos: platformer, topdown, shooter, roguelike, puzzle, generic, leveldesign" >&2
	exit 1
fi

# --- 8) Escribimos el nombre del proyecto en project.godot ---------------------
# Config/name de "Mi Juego" (que viene en la plantilla) al nombre elegido.
sed -i 's/config\/name="Mi Juego"/config\/name="'"$PROJECT_NAME"'"/' "$DEST_DIR/project.godot"

# --- 9) Mensaje final ----------------------------------------------------------
case "$GENRE" in
	platformer) GENRE_DESC="saltos con coyote time y jump buffer (ESPACIO para saltar)" ;;
	topdown)    GENRE_DESC="movimiento 8 direcciones en una sala cerrada (WASD)" ;;
	shooter)    GENRE_DESC="apuntar con el ratón y disparar balas (clic izquierdo)" ;;
	roguelike)  GENRE_DESC="mazmorra generada con código (regenerar con R)" ;;
	puzzle)     GENRE_DESC="tablero 3x3 de celdas clicables (rápido)" ;;
	leveldesign) GENRE_DESC="niveles como datos: LevelBuilder + progreso con Flux" ;;
	generic)    GENRE_DESC="base limpia sin género, partida de 8 direcciones" ;;
esac

echo ""
echo "------------------------------------------"
echo " ¡Listo! Proyecto \"$PROJECT_NAME\" creado."
echo "   Género:     $GENRE_DESC"
echo "   Abre con:   godot -e \"$DEST_DIR\""
echo "   Ejecuta:    godot --path \"$DEST_DIR\""
echo "------------------------------------------"