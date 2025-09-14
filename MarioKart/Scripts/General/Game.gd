#Game.gd
extends Node2D
@export var _map : Node2D
@export var _collision : Node
var _player : Racer  # Removido @export - se asigna dinámicamente
@export var _spriteHandler : Node2D
@export var _animationHandler : Node
@export var _backgroundElements : Node2D
@export var _minimap : Control

var _debugLabel : Label

func _ready():
	print("=== INICIANDO GAME.GD ===")
	print("Globals.selected_character al inicio: ", Globals.selected_character)
	
	# Configurar el personaje seleccionado ANTES de todo lo demás
	_setup_selected_character()
	
	# Verificar que _player fue asignado correctamente antes de continuar
	if not _player:
		print("ERROR CRITICO: _player no fue asignado en _setup_selected_character!")
		return
	
	print("Continuando con inicialización del juego...")
	_map.Setup(Globals.screenSize, _player)
	_collision.Setup()
	_spriteHandler.Setup(_map.ReturnWorldMatrix(), _map.texture.get_size().x, _player, _collision)
	_player.Setup(_map.texture.get_size().x, _spriteHandler)  # Pasar SpriteHandler al Player
	_animationHandler.Setup(_player)
	_minimap.Setup(_player, _map.texture)
	
	# Configurar debug label
	_debugLabel = $UI/Debug/PositionLabel
	
	print("=== JUEGO INICIALIZADO ===")
	print("Tamaño de pantalla del juego: ", Globals.screenSize)
	print("Tamaño del mapa: ", _map.texture.get_size())
	print("Personaje final en uso: ", _player.name if _player else "ERROR - NULL")
	print("Script del personaje: ", _player.get_script().get_global_name() if _player and _player.get_script() else "sin script")

func _setup_selected_character():
	print("=== DEBUG: Iniciando _setup_selected_character ===")
	print("Globals.selected_character = ", Globals.selected_character)
	
	# Obtener referencias a todos los personajes
	var mario_node = $"Sprite Handler/Racers/Mario"
	var luigi_node = $"Sprite Handler/Racers/Luigi"
	var bowser_node = $"Sprite Handler/Racers/Bowser"
	var donkey_kong_node = $"Sprite Handler/Racers/DonkeyKong"
	var yoshi_node = $"Sprite Handler/Racers/Yoshi"
	
	# Verificar que existan los nodos principales (Mario y Luigi son esenciales)
	if not mario_node:
		print("ERROR: Nodo Mario no encontrado!")
		return
	if not luigi_node:
		print("ERROR: Nodo Luigi no encontrado!")
		return
	
	print("Nodos encontrados - Mario: ", mario_node.name, " Luigi: ", luigi_node.name)
	if bowser_node:
		print("Bowser encontrado: ", bowser_node.name, " - Script: ", bowser_node.get_script().get_global_name() if bowser_node.get_script() else "sin script")
	else:
		print("ERROR: Nodo Bowser NO encontrado!")
	if donkey_kong_node:
		print("Donkey Kong encontrado: ", donkey_kong_node.name, " - Script: ", donkey_kong_node.get_script().get_global_name() if donkey_kong_node.get_script() else "sin script")
	else:
		print("ERROR: Nodo Donkey Kong NO encontrado!")
	if yoshi_node:
		print("Yoshi encontrado: ", yoshi_node.name, " - Script: ", yoshi_node.get_script().get_global_name() if yoshi_node.get_script() else "sin script")
	else:
		print("ERROR: Nodo Yoshi NO encontrado!")
	
	# Ocultar todos los personajes primero
	mario_node.visible = false
	luigi_node.visible = false
	if bowser_node:
		bowser_node.visible = false
	if donkey_kong_node:
		donkey_kong_node.visible = false
	if yoshi_node:
		yoshi_node.visible = false
	
	# Activar el personaje seleccionado
	print("Seleccionando personaje: '", Globals.selected_character, "'")
	match Globals.selected_character:
		"Luigi":
			luigi_node.visible = true
			_player = luigi_node
			print("✓ Luigi configurado como jugador principal")
		"Bowser":
			if bowser_node:
				bowser_node.visible = true
				_player = bowser_node
				print("✓ Bowser configurado como jugador principal")
			else:
				print("✗ ERROR: Bowser no encontrado, usando Mario por defecto")
				mario_node.visible = true
				_player = mario_node
		"DonkeyKong":
			if donkey_kong_node:
				donkey_kong_node.visible = true
				_player = donkey_kong_node
				print("✓ Donkey Kong configurado como jugador principal")
			else:
				print("✗ ERROR: Donkey Kong no encontrado, usando Mario por defecto")
				mario_node.visible = true
				_player = mario_node
		"Yoshi":
			if yoshi_node:
				yoshi_node.visible = true
				_player = yoshi_node
				print("✓ Yoshi configurado como jugador principal")
			else:
				print("✗ ERROR: Yoshi no encontrado, usando Mario por defecto")
				mario_node.visible = true
				_player = mario_node
		_:  # Mario por defecto
			mario_node.visible = true
			_player = mario_node
			print("✓ Mario configurado como jugador principal (por defecto)")
	
	# Verificar que _player esté correctamente asignado
	if not _player:
		print("ERROR: _player no fue asignado correctamente!")
		return
		
	print("=== DEBUG: _setup_selected_character completado ===")
	print("Jugador final (_player): ", _player.name if _player else "null")
	print("Tipo de _player: ", _player.get_script().get_global_name() if _player and _player.get_script() else "sin script")

func _process(delta):
	# PRUEBA TEMPORAL - Presiona ESPACIO para cambiar personajes
	if Input.is_action_just_pressed("ui_accept"):
		test_next_character()
	
	_map.Update(_player)
	_player.Update(_map.ReturnForward())
	_spriteHandler.Update(_map.ReturnWorldMatrix())
	_animationHandler.Update()
	_backgroundElements.Update(_map.ReturnMapRotation())
	_minimap.UpdateMinimap()
	
	# Actualizar debug info
	if _debugLabel:
		var playerPos = _player._mapPosition
		_debugLabel.text = "Position: (%.1f, %.1f, %.1f)\nSpeed: %.1f\nCharacter: %s\nPress SPACE to change character" % [playerPos.x, playerPos.y, playerPos.z, _player.ReturnMovementSpeed(), Globals.selected_character]

# Función temporal para probar todos los personajes
var test_characters = ["Mario", "Luigi", "Bowser", "DonkeyKong"]
var current_test_index = 0

func test_next_character():
	current_test_index = (current_test_index + 1) % test_characters.size()
	var new_character = test_characters[current_test_index]
	print("\n=== PRUEBA: Cambiando a ", new_character, " ===")
	Globals.selected_character = new_character
	_setup_selected_character()
	print("=== FIN PRUEBA ===\n")
