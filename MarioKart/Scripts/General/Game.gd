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
var _victoryScreen : Control
var _victoryVideoPlayer : VideoStreamPlayer
var _victoryAnimationPlayer : AnimationPlayer
var _pulsingTween : Tween
var _isVictoryScreenActive : bool = false
var _tKeyPressed : bool = false
var _vKeyPressed : bool = false

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
	
	# Configurar pantalla de victoria
	setup_victory_screen()
	
	# Añadir este nodo al grupo para recibir notificaciones
	add_to_group("game_manager")
	
	# Inicializar tiempo de carrera
	Globals.raceStartTime = Time.get_ticks_msec()
	
	print("=== JUEGO INICIALIZADO ===")
	print("Tamaño de pantalla del juego: ", Globals.screenSize)
	print("Tamaño del mapa: ", _map.texture.get_size())
	print("Sistema de vueltas inicializado - Meta: ", Globals.finishLinePosition, " | Checkpoint: ", Globals.checkpointPosition)
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
	if _isVictoryScreenActive:
		# Solo procesar input para reiniciar si la pantalla de victoria está activa
		if Input.is_key_pressed(KEY_ENTER) or Input.is_key_pressed(KEY_SPACE):
			restart_race()
		return
	
	# Funciones de testing:
	# Presionar T para simular completar una vuelta (solo una vez por presión)
	if Input.is_key_pressed(KEY_T):
		if !_tKeyPressed and !Globals.raceFinished:
			_tKeyPressed = true
			simulate_lap_completion()
	else:
		_tKeyPressed = false
	
	# Presionar V para forzar mostrar pantalla de victoria (solo una vez por presión)
	if Input.is_key_pressed(KEY_V):
		if !_vKeyPressed and !_isVictoryScreenActive:
			_vKeyPressed = true
			force_victory_for_testing()
	else:
		_vKeyPressed = false
	
	# PRUEBA TEMPORAL - Presiona ESPACIO para cambiar personajes (solo si no hay victoria)
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
		var playerPos2D = Vector2(playerPos.x, playerPos.z)
		var lapInfo = "Vuelta: %d/%d" % [Globals.currentLap, Globals.totalLaps]
		var checkpointStatus = "CP: " + ("✓" if Globals.hasPassedCheckpoint else "✗")
		var raceStatus = "Estado: " + ("FINISH" if Globals.raceFinished else "RACING")
		var distanceToFinish = playerPos2D.distance_to(Globals.finishLinePosition)
		var distanceToCheckpoint = playerPos2D.distance_to(Globals.checkpointPosition)
		var victoryStatus = "Victoria: " + ("SÍ" if _isVictoryScreenActive else "NO")
		
		# Información de progreso más detallada
		var nextTarget = "→ " + ("META (64,64)" if Globals.hasPassedCheckpoint else "CHECKPOINT (500,350)")
		var nextDistance = distanceToCheckpoint if !Globals.hasPassedCheckpoint else distanceToFinish
		var progressIndicator = "🔥" if nextDistance < 120 else "●"
		
		var raceTime = (Time.get_ticks_msec() - Globals.raceStartTime) / 1000.0
		var distanceText = "Distancia a META: %.0f" % distanceToFinish
		var proximityIcon = "🔥" if distanceToFinish < 100 else "○"
		_debugLabel.text = "Pos: (%.0f, %.0f) | Speed: %.1f | %s\n%s | %s | Tiempo: %.1fs\n%s %s\n%s %s\nTEST: V=Victoria, T=Vuelta, SPACE=Cambiar personaje" % [playerPos.x, playerPos.z, _player.ReturnMovementSpeed(), Globals.selected_character, lapInfo, raceStatus, raceTime, proximityIcon, distanceText, victoryStatus, "Meta en: (64,64)"]

# Configurar la pantalla de victoria con video
func setup_victory_screen():
	print("=== CONFIGURANDO PANTALLA DE VICTORIA CON VIDEO ===")
	
	# Crear la pantalla de victoria
	_victoryScreen = Control.new()
	_victoryScreen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_victoryScreen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Fondo negro completo
	var background = ColorRect.new()
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.color = Color.BLACK
	_victoryScreen.add_child(background)
	
	# Crear contenedor para controlar el tamaño del video
	var videoContainer = AspectRatioContainer.new()
	videoContainer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	videoContainer.stretch_mode = AspectRatioContainer.STRETCH_FIT
	videoContainer.alignment_horizontal = AspectRatioContainer.ALIGNMENT_CENTER
	videoContainer.alignment_vertical = AspectRatioContainer.ALIGNMENT_CENTER
	
	# Crear el reproductor de video
	_victoryVideoPlayer = VideoStreamPlayer.new()
	_victoryVideoPlayer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_victoryVideoPlayer.expand = true
	
	# Añadir el video al contenedor
	videoContainer.add_child(_victoryVideoPlayer)
	
	print("📺 Video configurado con AspectRatioContainer")
	
	# Cargar el video en formato OGV (compatible con Godot)
	var videoPath = "res://imagenes_final/yoshiVictory.ogv"
	print("🔍 Intentando cargar video desde: ", videoPath)
	
	# Verificar si el archivo existe
	if ResourceLoader.exists(videoPath):
		print("✅ Archivo encontrado, cargando...")
		
		# Intentar cargar como recurso
		var videoStream = load(videoPath)
		if videoStream != null:
			print("✅ Video cargado como recurso")
			_victoryVideoPlayer.stream = videoStream
			_victoryVideoPlayer.autoplay = false
			_victoryVideoPlayer.loop = true
		else:
			print("❌ Error al cargar video como recurso")
			# Fallback: crear VideoStreamTheora manualmente
			var theoraStream = VideoStreamTheora.new()
			theoraStream.file = videoPath
			_victoryVideoPlayer.stream = theoraStream
			_victoryVideoPlayer.autoplay = false
			_victoryVideoPlayer.loop = true
			print("🔄 Usando VideoStreamTheora como fallback")
	else:
		print("❌ Video no encontrado en: ", videoPath)
		print("🔍 Verificando archivos disponibles...")
		# Mostrar qué archivos hay disponibles para debug
		var dir = DirAccess.open("res://imagenes_final/")
		if dir:
			dir.list_dir_begin()
			var fileName = dir.get_next()
			while fileName != "":
				print("📁 Archivo encontrado: ", fileName)
				fileName = dir.get_next()
			dir.list_dir_end()
	
	_victoryScreen.add_child(videoContainer)
	
	# Texto de instrucciones sobre el video
	var instructionLabel = Label.new()
	instructionLabel.text = "Presiona ENTER para jugar de nuevo"
	instructionLabel.add_theme_color_override("font_color", Color.WHITE)
	instructionLabel.add_theme_font_size_override("font_size", 24)
	instructionLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	instructionLabel.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	instructionLabel.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	instructionLabel.position = Vector2(-300, -50)
	instructionLabel.size = Vector2(600, 40)
	_victoryScreen.add_child(instructionLabel)
	
	# Añadir a la escena
	$UI.add_child(_victoryScreen)
	_victoryScreen.visible = false
	print("✅ Pantalla de victoria con video configurada")

# Iniciar la animación de palpitación
# Función de fallback si el video no funciona
func create_fallback_victory_text():
	print("🔄 Creando texto de fallback para la victoria...")
	
	# Crear texto de YOU WIN
	var youWinLabel = Label.new()
	youWinLabel.text = "¡YOU WIN!"
	youWinLabel.add_theme_font_size_override("font_size", 72)
	youWinLabel.add_theme_color_override("font_color", Color.YELLOW)
	youWinLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	youWinLabel.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	youWinLabel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	youWinLabel.position = Vector2(-300, -100)
	youWinLabel.size = Vector2(600, 100)
	_victoryScreen.add_child(youWinLabel)
	
	# Crear texto de PRIMER LUGAR
	var firstPlaceLabel = Label.new()
	firstPlaceLabel.text = "🏆 PRIMER LUGAR 🏆"
	firstPlaceLabel.add_theme_font_size_override("font_size", 48)
	firstPlaceLabel.add_theme_color_override("font_color", Color.GOLD)
	firstPlaceLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	firstPlaceLabel.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	firstPlaceLabel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	firstPlaceLabel.position = Vector2(-300, 0)
	firstPlaceLabel.size = Vector2(600, 80)
	_victoryScreen.add_child(firstPlaceLabel)
	
	print("✅ Texto de fallback creado")

# Mostrar la pantalla de victoria
func show_victory_screen():
	print("=== MOSTRANDO VICTORIA CON VIDEO ===")
	if _isVictoryScreenActive:
		print("Victoria ya activa")
		return
		
	if not _victoryScreen:
		print("Error: Pantalla de victoria no existe")
		return
		
	_isVictoryScreenActive = true
	_victoryScreen.visible = true
	
	# Reproducir el video de victoria
	if _victoryVideoPlayer:
		if _victoryVideoPlayer.stream:
			print("🎬 Reproduciendo video de victoria...")
			_victoryVideoPlayer.play()
			print("📺 Estado del reproductor: ", _victoryVideoPlayer.get_stream_name())
		else:
			print("❌ No hay stream de video cargado")
			# Crear texto de fallback si no hay video
			create_fallback_victory_text()
	else:
		print("❌ VideoStreamPlayer no existe")
		create_fallback_victory_text()
	
	print("✅ Victoria con video activada - ENTER para reiniciar")

# Función para simular completar una vuelta (testing)
func simulate_lap_completion():
	print("=== SIMULANDO VUELTA ===")
	if Globals.raceFinished:
		print("La carrera ya terminó")
		return
		
	Globals.currentLap += 1
	print("Vuelta: ", Globals.currentLap, "/", Globals.totalLaps)
	
	if Globals.currentLap >= Globals.totalLaps:
		Globals.raceFinished = true
		print("¡Carrera terminada! Mostrando victoria...")
		show_victory_screen()
		
# Función simple para mostrar pantalla de victoria
func force_victory_for_testing():
	print("=== FORZANDO VICTORIA ===")
	if _isVictoryScreenActive:
		print("La pantalla ya está activa")
		return
	Globals.raceFinished = true
	show_victory_screen()

# Reiniciar la carrera
func restart_race():
	print("=== REINICIANDO CARRERA ===")
	_isVictoryScreenActive = false
	
	# Ocultar pantalla de victoria
	if _victoryScreen:
		_victoryScreen.visible = false
	
	# Detener video de victoria
	if _victoryVideoPlayer:
		_victoryVideoPlayer.stop()
		print("🎬 Video de victoria detenido")
	
	# Detener animación
	if _pulsingTween:
		_pulsingTween.kill()
	
	# Reiniciar variables globales (vueltas, tiempo, etc.)
	Globals.reset_race()
	
	# Reposicionar y reiniciar jugador completamente
	if _player:
		# Reposicionar a la posición inicial
		if _player.has_method("SetMapPosition"):
			_player.SetMapPosition(Globals.startPosition)
			print("🏁 Jugador reposicionado a: ", Globals.startPosition)
		
		# Reiniciar completamente el estado del jugador
		if _player.has_method("ResetPlayerState"):
			_player.ResetPlayerState()
	
	print("✅ Carrera reiniciada - Jugador en posición inicial")

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
