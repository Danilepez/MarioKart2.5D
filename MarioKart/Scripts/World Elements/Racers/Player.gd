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

func ReturnPlayerInput() -> Vector2:
	_inputDir.x = Input.get_action_strength("Left") - Input.get_action_strength("Right")
	_inputDir.y = -Input.get_action_strength("Forward")
	return Vector2(_inputDir.x, _inputDir.y)
