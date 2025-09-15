#Player.gd
class_name Player
extends Racer

# Referencia al SpriteHandler para verificar colisiones con hazards
var _spriteHandler : Node2D

func Setup(mapSize : int, spriteHandler : Node2D = null):
	SetMapSize(mapSize)
	_spriteHandler = spriteHandler

func Update(mapForward : Vector3):
	if(_isPushedBack):
		ApplyCollisionBump()
	
	var nextPos : Vector3 = _mapPosition + ReturnVelocity()
	var nextPixelPos : Vector2i = Vector2i(ceil(nextPos.x), ceil(nextPos.z))
	
	# Verificar colisiones con paredes
	if(_collisionHandler.IsCollidingWithWall(Vector2i(ceil(nextPos.x), ceil(_mapPosition.z)))):
		nextPos.x = _mapPosition.x 
		SetCollisionBump(Vector3(-sign(ReturnVelocity().x), 0, 0))
	if(_collisionHandler.IsCollidingWithWall(Vector2i(ceil(_mapPosition.x), ceil(nextPos.z)))):
		nextPos.z = _mapPosition.z
		SetCollisionBump(Vector3(0, 0, -sign(ReturnVelocity().z)))
	
	# Verificar colisiones con hazards (tubos)
	if _spriteHandler and _spriteHandler.has_method("CheckHazardCollision"):
		if _spriteHandler.CheckHazardCollision(nextPos):
			# Obtener dirección de empuje
			var pushDirection = _spriteHandler.GetHazardCollisionDirection(nextPos)
			if pushDirection != Vector3.ZERO:
				# Aplicar empuje en dirección opuesta al hazard
				SetCollisionBump(pushDirection)
				# Revertir movimiento
				nextPos = _mapPosition
	
	HandleRoadType(nextPixelPos, _collisionHandler.ReturnCurrentRoadType(nextPixelPos))
	
	SetMapPosition(nextPos)
	UpdateMovementSpeed()
	UpdateVelocity(mapForward)
	
	# Verificar sistema de vueltas
	CheckLapProgress()

func ReturnPlayerInput() -> Vector2:
	_inputDir.x = Input.get_action_strength("Left") - Input.get_action_strength("Right")
	_inputDir.y = -Input.get_action_strength("Forward")
	return Vector2(_inputDir.x, _inputDir.y)

# Función para verificar el progreso de las vueltas
func CheckLapProgress():
	if Globals.raceFinished:
		return
	
	var playerPos2D = Vector2(_mapPosition.x, _mapPosition.z)
	var playerY = playerPos2D.y
	var playerX = playerPos2D.x
	
	# Debug: mostrar posición cada 60 frames (1 segundo)
	if Engine.get_process_frames() % 60 == 0:
		var beforeAfter = "ANTES" if Globals.playerBeforeFinishLine else "DESPUÉS"
		print("🎯 Pos: (%.0f,%.0f) | %s de meta | Vuelta: %d/%d" % [playerX, playerY, beforeAfter, Globals.currentLap, Globals.totalLaps])
	
	# Sistema de detección de CRUCE real
	var finishLineY = Globals.finishLineY
	var isInFinishArea = (playerX >= 80 and playerX <= 160)  # Área amplia que incluye pista y bordes
	
	# Determinar si está antes o después de la línea de meta
	var isBeforeFinishLine = (playerY > finishLineY + 5)  # Un poco más allá para evitar falsos positivos
	var isAfterFinishLine = (playerY < finishLineY - 5)   # Un poco más acá para evitar falsos positivos
	
	# DETECCIÓN DEL CRUCE: De ANTES a DESPUÉS
	if Globals.playerBeforeFinishLine and isAfterFinishLine and isInFinishArea:
		var currentTime = Time.get_ticks_msec()
		# Verificar tiempo mínimo entre vueltas (3 segundos)
		if (currentTime - Globals.lastLapTime) >= 3000:
			print("🏁 ¡VUELTA COMPLETADA! Cruzó de ANTES (%.0f) a DESPUÉS (%.0f)" % [finishLineY + 5, playerY])
			Globals.lastLapTime = currentTime
			Globals.playerBeforeFinishLine = false
			CompleteLap()
	
	# Actualizar estado: si está claramente antes de la línea, marcar como "antes"
	elif isBeforeFinishLine:
		Globals.playerBeforeFinishLine = true

# Función que se ejecuta al completar una vuelta
func CompleteLap():
	Globals.currentLap += 1
	print("🏁 ¡VUELTA COMPLETADA! Vuelta: %d/%d" % [Globals.currentLap, Globals.totalLaps])
	
	if Globals.currentLap >= Globals.totalLaps:
		Globals.raceFinished = true
		print("🏆 ¡CARRERA TERMINADA! Buscando Game manager...")
		# Buscar el nodo Game directamente
		var gameNode = get_tree().get_first_node_in_group("game_manager")
		if gameNode == null:
			gameNode = get_node("/root/Main")  # Intento alternativo
		if gameNode and gameNode.has_method("show_victory_screen"):
			print("✅ Llamando a show_victory_screen...")
			gameNode.show_victory_screen()
		else:
			print("❌ No se pudo encontrar el Game manager")

# Función para reiniciar completamente el estado del jugador
func ResetPlayerState():
	print("🔄 Reiniciando estado del jugador...")
	
	# Reiniciar velocidad y movimiento
	_velocity = Vector3.ZERO
	_movementSpeed = 0.0
	_currentMoveDirection = 0
	_inputDir = Vector2.ZERO
	
	# Reiniciar efectos de colisión
	_isPushedBack = false
	_currPushbackTime = 0.0
	_bumpDir = Vector3.ZERO
	
	# Reiniciar multiplicador de velocidad
	_speedMultiplier = 1.0
	_onRoadType = Globals.RoadType.ROAD
	
	print("✅ Estado del jugador reiniciado")
