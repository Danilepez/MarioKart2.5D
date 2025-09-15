#Globals.gd
extends Node

var screenSize : Vector2 = Vector2(480, 360)

# Variables del sistema de vueltas
var currentLap : int = 0
var totalLaps : int = 3
var raceFinished : bool = false
var hasPassedCheckpoint : bool = false
var raceStartTime : int = 0
var minimumLapTime : int = 2000  # Tiempo mínimo entre vueltas (2 segundos)
var lastLapTime : int = 0  # Tiempo de la última vuelta completada
var useSimpleDetection : bool = true  # Usar detección simple sin checkpoint

# Variables para detección precisa del cruce de meta
var playerBeforeFinishLine : bool = true  # Si el jugador está antes de la línea de meta
var finishLineY : float = 504.0  # Coordenada Y de la línea de meta

# Posición inicial del jugador (posición de inicio)
var startPosition : Vector3 = Vector3(123, 0, 550)  # X, Y, Z donde Y=0 (altura) y Z un poco después de la meta

# Posiciones importantes del mapa para detectar vueltas (basadas en las ubicaciones del circuito)
var finishLinePosition : Vector2 = Vector2(123, 513)  # Posición de la línea de meta (donde está el jugador ahora)
var checkpointPosition : Vector2 = Vector2(500, 350)  # Punto de control cerca del lago (mitad del circuito)

enum RoadType {
	VOID = 0,
	ROAD = 1,
	GRAVEL = 2,
	OFF_ROAD = 3,
	WALL = 4,
	SINK = 5
}

# Función para reiniciar la carrera
func reset_race():
	currentLap = 0
	raceFinished = false
	hasPassedCheckpoint = false
	playerBeforeFinishLine = true
	raceStartTime = Time.get_ticks_msec()
	lastLapTime = raceStartTime 
