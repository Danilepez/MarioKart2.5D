#Minimap.gd
extends Control

@export var _mapBackground : TextureRect
@export var _playerIcon : Control
@export var _mapTexture : Texture2D
var _mapSize : Vector2 = Vector2.ZERO
var _player : Racer

func Setup(player : Racer, mapTexture : Texture2D):
	_player = player
	_mapTexture = mapTexture
	_mapSize = _mapTexture.get_size()
	
	print("=== MINIMAP SETUP ===")
	print("Tamaño del mapa: ", _mapSize)
	print("Tamaño del minimapa: ", size)
	
	# Configurar el fondo del minimapa - mostrar TODO el mapa
	if _mapBackground:
		_mapBackground.texture = _mapTexture
		_mapBackground.size = size
		_mapBackground.position = Vector2.ZERO
		print("Minimapa configurado con textura del mapa completo")
	
	# Configurar el ícono del jugador - punto rojo más pequeño
	if _playerIcon:
		_playerIcon.size = Vector2(6, 6)
		print("Ícono del jugador configurado (6x6 píxeles)")

func UpdateMinimap():
	if not _player or not _playerIcon or not _mapBackground:
		return
	
	# Obtener la posición del jugador en coordenadas del mundo
	var playerMapPos : Vector3 = _player._mapPosition
	
	# Convertir directamente basándose en el tamaño del mapa
	# Las coordenadas van de 0 a tamaño del mapa
	var normalizedX = playerMapPos.x / _mapSize.x
	var normalizedZ = playerMapPos.z / _mapSize.y
	
	# Convertir a coordenadas del minimapa
	var iconPosX = normalizedX * size.x
	var iconPosZ = normalizedZ * size.y
	
	# Centrar el ícono
	var iconSize = _playerIcon.size
	var finalPos = Vector2(iconPosX - iconSize.x/2, iconPosZ - iconSize.y/2)
	
	# NO limitar dentro del área - permitir que se salga como antes
	# para mantener la precisión del movimiento
	_playerIcon.position = finalPos
	
	# Debug menos frecuente
	if randf() < 0.005:
		print("=== MINIMAP DEBUG ===")
		print("Pos jugador mundo: (", playerMapPos.x, ", ", playerMapPos.z, ")")
		print("Normalizado: (", normalizedX, ", ", normalizedZ, ")")
		print("Pos en minimapa: ", finalPos)
		print("Tamaño minimapa: ", size)