# Opponent.gd - Sistema de IA para oponentes en la carrera
extends Racer

# Variables de IA
var ai_target_speed : float = 0.8  # Velocidad objetivo (0.8 = 80% de la velocidad máxima)
var ai_reaction_time : float = 0.3  # Tiempo de reacción para cambios
var ai_aggression : float = 0.5    # Agresividad (0-1)
var ai_skill_level : float = 0.7   # Nivel de habilidad (0-1)

# Variables de movimiento aleatorio
var random_offset : float = 0.0
var random_change_timer : float = 0.0
var random_change_interval : float = 2.0  # Cambiar dirección cada 2 segundos

# Variables de navegación
var track_progress : float = 0.0
var target_line : float = 0.0  # Línea objetivo en la pista (-1 a 1)

# Configuración del personaje
var character_name : String = "mario"
var is_player_controlled : bool = false

# Variables de input de IA (simulan input del jugador)
var throttle_input : float = 0.0
var steering_input : float = 0.0

# Variables de estado del vehículo (acceso a propiedades del Racer)
var current_speed : float = 0.0
var max_speed : float = 120.0
var track_position : float = 0.0

func _ready():
	# No llamar super._ready() ya que Racer no lo tiene definido
	setup_ai_personality()
	setup_character_sprites()

func setup_ai_personality():
	# Personalidades diferentes según el personaje
	match character_name:
		"mario":
			ai_skill_level = 0.8
			ai_aggression = 0.6
			ai_target_speed = 0.85
		"luigi":
			ai_skill_level = 0.7
			ai_aggression = 0.4
			ai_target_speed = 0.8
		"bowser":
			ai_skill_level = 0.9
			ai_aggression = 0.9
			ai_target_speed = 0.9
		"donkikon":
			ai_skill_level = 0.6
			ai_aggression = 0.7
			ai_target_speed = 0.75

func setup_character_sprites():
	# Configurar sprites según el personaje seleccionado
	var sprite_path = "res://Textures/Racers/" + character_name.capitalize() + " Back.png"
	if ResourceLoader.exists(sprite_path):
		var texture = load(sprite_path) as Texture2D
		# Buscar el componente de sprite en este nodo
		var sprite_node = get_node_or_null("Sprite2D")
		if sprite_node and texture:
			sprite_node.texture = texture
		print("✅ Oponente configurado: ", character_name)
	else:
		print("❌ Sprite no encontrado para oponente: ", character_name)

func _physics_process(delta):
	if not is_player_controlled:
		process_ai_movement(delta)
		apply_ai_inputs()
	# No llamar super._physics_process() ya que Racer no lo tiene definido

func apply_ai_inputs():
	# Aplicar los inputs de IA al sistema de movimiento del Racer
	if throttle_input > 0.5:
		_currentMoveDirection = 1  # Mover hacia adelante
	else:
		_currentMoveDirection = 0  # No moverse
	
	# Aplicar steering a la dirección de input (simulando input del jugador)
	_inputDir.x = steering_input
	_inputDir.y = throttle_input - 0.5  # Convertir throttle a dirección Y

func process_ai_movement(delta):
	# Actualizar timer de cambios aleatorios
	random_change_timer += delta
	if random_change_timer >= random_change_interval:
		generate_random_movement()
		random_change_timer = 0.0
	
	# Calcular inputs de IA
	var ai_throttle = calculate_ai_throttle()
	var ai_steering = calculate_ai_steering()
	
	# Aplicar inputs con algo de ruido aleatorio
	throttle_input = ai_throttle + random_offset * 0.1
	steering_input = ai_steering + random_offset * 0.2
	
	# Limitar inputs
	throttle_input = clamp(throttle_input, 0.0, 1.0)
	steering_input = clamp(steering_input, -1.0, 1.0)

func calculate_ai_throttle() -> float:
	# Acelerar hacia la velocidad objetivo usando las variables de Racer
	current_speed = _movementSpeed  # Obtener velocidad actual del Racer
	max_speed = _maxMovementSpeed   # Obtener velocidad máxima del Racer
	
	var current_speed_ratio = current_speed / max_speed
	var target_ratio = ai_target_speed
	
	if current_speed_ratio < target_ratio:
		return 1.0  # Acelerar a fondo
	elif current_speed_ratio > target_ratio * 1.1:
		return 0.3  # Reducir aceleración
	else:
		return 0.8  # Mantener velocidad

func calculate_ai_steering() -> float:
	# Navegación básica con variación aleatoria
	var base_steering = target_line * ai_skill_level
	
	# Añadir algo de variación para movimiento natural
	var steering_variation = sin(Time.get_ticks_msec() * 0.001) * 0.1
	
	# Combinar steering
	var final_steering = base_steering + steering_variation
	
	# Aplicar nivel de habilidad (menos habilidad = más errático)
	final_steering *= (0.5 + ai_skill_level * 0.5)
	
	return clamp(final_steering, -1.0, 1.0)

func generate_random_movement():
	# Generar nuevo offset aleatorio
	random_offset = randf_range(-0.5, 0.5)
	
	# Cambiar línea objetivo ocasionalmente
	if randf() < 0.3:  # 30% probabilidad
		target_line = randf_range(-0.5, 0.5)
	
	# Ajustar intervalo de cambio aleatoriamente
	random_change_interval = randf_range(1.5, 3.0)

func set_character(character : String):
	if character == "":
		print("❌ Error: Nombre de personaje vacío")
		return
		
	character_name = character
	print("🔧 Configurando personaje IA: ", character_name)
	setup_ai_personality()
	setup_character_sprites()

func set_starting_position(pos : Vector3, track_pos : float):
	# Posicionar al oponente en la línea de salida (convertir Vector3 a Vector2)
	position = Vector2(pos.x, pos.y)  # Convertir Vector3 a Vector2
	track_position = track_pos
	track_progress = 0.0
	print("🏁 Oponente ", character_name, " posicionado en: ", position)
