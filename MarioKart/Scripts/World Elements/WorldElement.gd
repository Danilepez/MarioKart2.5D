#WorldElement.gd
class_name WorldElement
extends Node2D

@export var _spriteGFX : Node  # Usar Node para máxima compatibilidad
@export var _mapPosition : Vector3 = Vector3(146, 0, 537)
var _mapSize : int = 1024
var _screenPosition : Vector2i

func ReturnSpriteGraphic() -> Node: return _spriteGFX  # Retornar Node base

func SetMapSize(size : int): _mapSize = size
func ReturnMapPosition() -> Vector3: return _mapPosition / _mapSize
func SetMapPosition(mapPosition : Vector3): _mapPosition = mapPosition

func ReturnScreenPosition() -> Vector2i: return _screenPosition
func SetScreenPosition(screenPosition : Vector2i): 
	_screenPosition = screenPosition
	position = _screenPosition
