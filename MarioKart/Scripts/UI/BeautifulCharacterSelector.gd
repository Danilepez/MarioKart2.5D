# BeautifulCharacterSelector.gd
extends Control

# Referencias a los personajes
var character_buttons : Array[TextureButton] = []
var character_names : Array[String] = ["Mario", "Luigi", "Bowser", "DonkeyKong", "Yoshi"]
var current_selection : int = 0

# Referencias a elementos UI
@onready var background_selector = $SelectorBackground
@onready var title_label = $UI/TitleLabel
@onready var character_name_label = $UI/CharacterNameLabel
@onready var start_button = $UI/StartButton
@onready var character_container = $UI/CharacterContainer

# Efectos y animaciones
var selection_tween : Tween
var hover_tween : Tween

# Señales
signal character_selected(character_name: String)

func _ready():
	print("=== INICIALIZANDO BEAUTIFUL CHARACTER SELECTOR ===")
	setup_ui()
	setup_character_buttons()
	update_selection_display()
	animate_entrance()
	
func setup_ui():
	# Configurar el título
	if title_label:
		title_label.text = "🏆 SELECCIONA TU PILOTO 🏆"
		title_label.add_theme_font_size_override("font_size", 28)
		title_label.add_theme_color_override("font_color", Color.GOLD)
	
	# Configurar botón de inicio
	if start_button:
		start_button.text = "¡COMENZAR CARRERA!"
		start_button.pressed.connect(_on_start_pressed)

func setup_character_buttons():
	print("Configurando botones de personajes...")
	
	# Limpiar botones existentes si los hay
	for child in character_container.get_children():
		child.queue_free()
	character_buttons.clear()
	
	# Crear contenedor horizontal para los personajes
	var h_container = HBoxContainer.new()
	h_container.add_theme_constant_override("separation", 20)
	character_container.add_child(h_container)
	
	# Texturas de personajes
	var character_textures = [
		"res://Textures/Racers/mario-3-0000-Photoroom.png",    # Mario
		"res://Textures/Racers/luigi-3-0000-Photoroom.png",    # Luigi  
		"res://Textures/Racers/bowser-3.png",                  # Bowser
		"res://Textures/Racers/donkeykongjr-3.png",           # DonkeyKong
		"res://Textures/Racers/yoshi.png"                      # Yoshi
	]
	
	# Crear botón para cada personaje
	for i in character_names.size():
		var character_name = character_names[i]
		var texture_path = character_textures[i]
		
		# Crear contenedor vertical para cada personaje
		var v_container = VBoxContainer.new()
		v_container.add_theme_constant_override("separation", 10)
		
		# Crear el botón con imagen del personaje
		var button = TextureButton.new()
		button.name = character_name + "Button"
		
		# Cargar la textura
		if ResourceLoader.exists(texture_path):
			var texture = load(texture_path) as Texture2D
			button.texture_normal = texture
			print("✅ Textura cargada para ", character_name, ": ", texture_path)
		else:
			print("❌ No se pudo cargar textura para ", character_name, ": ", texture_path)
		
		# Configurar el botón
		button.custom_minimum_size = Vector2(80, 80)
		button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
		
		# Conectar señales
		button.pressed.connect(_on_character_pressed.bind(i))
		button.mouse_entered.connect(_on_character_hover.bind(i))
		button.mouse_exited.connect(_on_character_unhover.bind(i))
		
		# Crear etiqueta con nombre del personaje
		var name_label = Label.new()
		name_label.text = character_name
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_label.add_theme_font_size_override("font_size", 16)
		name_label.add_theme_color_override("font_color", Color.WHITE)
		
		# Agregar elementos al contenedor vertical
		v_container.add_child(button)
		v_container.add_child(name_label)
		
		# Agregar al contenedor horizontal
		h_container.add_child(v_container)
		character_buttons.append(button)
	
	print("✅ Configurados ", character_buttons.size(), " botones de personajes")

func _on_character_pressed(index: int):
	var character_name = character_names[index]
	print("🎮 Personaje seleccionado: ", character_name)
	
	# Mensaje especial para DonkeyKong como mencionaste
	if character_name == "DonkeyKong":
		print("🐵 ¡Has seleccionado al mono! DonkeyKong está listo para correr!")
	
	current_selection = index
	update_selection_display()
	animate_selection(index)
	create_selection_particles(character_buttons[index])
	
func _on_character_hover(index: int):
	animate_hover(index, true)
	
func _on_character_unhover(index: int):
	animate_hover(index, false)

func update_selection_display():
	# Actualizar el nombre del personaje seleccionado
	if character_name_label:
		var character_name = character_names[current_selection]
		
		# Mensaje especial para DonkeyKong (el mono)
		if character_name == "DonkeyKong":
			character_name_label.text = "🐵 " + character_name + " 🐵"
			character_name_label.add_theme_color_override("font_color", Color.ORANGE)
		else:
			character_name_label.text = character_name
			character_name_label.add_theme_color_override("font_color", Color.YELLOW)
	
	# Actualizar apariencia de los botones
	for i in character_buttons.size():
		var button = character_buttons[i]
		if i == current_selection:
			# Botón seleccionado - más grande y con brillo
			button.modulate = Color(1.2, 1.2, 1.2, 1.0)
			button.scale = Vector2(1.1, 1.1)
		else:
			# Botones no seleccionados - normales
			button.modulate = Color(0.8, 0.8, 0.8, 1.0)
			button.scale = Vector2(1.0, 1.0)

func animate_selection(index: int):
	if selection_tween:
		selection_tween.kill()
	
	selection_tween = create_tween()
	selection_tween.set_parallel(true)
	
	var button = character_buttons[index]
	
	# Animación de "rebote" más dramática al seleccionar
	selection_tween.tween_property(button, "scale", Vector2(1.4, 1.4), 0.15)
	selection_tween.tween_property(button, "scale", Vector2(0.9, 0.9), 0.1).set_delay(0.15)
	selection_tween.tween_property(button, "scale", Vector2(1.1, 1.1), 0.2).set_delay(0.25)
	
	# Efecto de brillo dorado
	selection_tween.tween_property(button, "modulate", Color(2.0, 2.0, 1.0, 1.0), 0.1)
	selection_tween.tween_property(button, "modulate", Color(1.2, 1.2, 1.2, 1.0), 0.3).set_delay(0.2)
	
	# Animación de rotación sutil
	selection_tween.tween_property(button, "rotation", deg_to_rad(10), 0.1)
	selection_tween.tween_property(button, "rotation", deg_to_rad(-5), 0.1).set_delay(0.1)
	selection_tween.tween_property(button, "rotation", 0, 0.2).set_delay(0.2)

func animate_hover(index: int, is_hovering: bool):
	if hover_tween:
		hover_tween.kill()
	
	hover_tween = create_tween()
	var button = character_buttons[index]
	
	if is_hovering and index != current_selection:
		# Efecto hover - ligeramente más grande
		hover_tween.tween_property(button, "scale", Vector2(1.05, 1.05), 0.1)
		hover_tween.tween_property(button, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.1)
	elif not is_hovering and index != current_selection:
		# Volver al estado normal
		hover_tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.1)
		hover_tween.tween_property(button, "modulate", Color(0.8, 0.8, 0.8, 1.0), 0.1)

func _on_start_pressed():
	var selected_character = character_names[current_selection]
	print("🚗 Iniciando carrera con: ", selected_character)
	
	# Guardar selección globalmente
	Globals.selected_character = selected_character
	
	# Emitir señal
	character_selected.emit(selected_character)
	
	# Cambiar a escena principal
	get_tree().change_scene_to_file("res://Scenes/main.tscn")

# Funciones para controles de teclado
func _input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_LEFT, KEY_A:
				navigate_selection(-1)
			KEY_RIGHT, KEY_D:
				navigate_selection(1)
			KEY_ENTER, KEY_SPACE:
				_on_start_pressed()

func navigate_selection(direction: int):
	current_selection = (current_selection + direction) % character_names.size()
	if current_selection < 0:
		current_selection = character_names.size() - 1
	
	update_selection_display()
	animate_selection(current_selection)

# Animación de entrada espectacular
func animate_entrance():
	print("🎬 Iniciando animación de entrada...")
	
	# Ocultar elementos inicialmente
	if title_label:
		title_label.modulate.a = 0.0
		title_label.scale = Vector2(0.5, 0.5)
	
	if character_name_label:
		character_name_label.modulate.a = 0.0
	
	if start_button:
		start_button.modulate.a = 0.0
		start_button.scale = Vector2(0.8, 0.8)
	
	# Ocultar botones de personajes
	for button in character_buttons:
		button.modulate.a = 0.0
		button.scale = Vector2(0.3, 0.3)
		button.rotation = deg_to_rad(180)
	
	# Crear tween de entrada
	var entrance_tween = create_tween()
	entrance_tween.set_parallel(true)
	
	# Animar título
	if title_label:
		entrance_tween.tween_property(title_label, "modulate:a", 1.0, 0.8).set_delay(0.2)
		entrance_tween.tween_property(title_label, "scale", Vector2(1.0, 1.0), 0.8).set_delay(0.2)
		entrance_tween.set_ease(Tween.EASE_OUT)
		entrance_tween.set_trans(Tween.TRANS_BACK)
	
	# Animar botones de personajes uno por uno
	for i in character_buttons.size():
		var button = character_buttons[i]
		var delay = 0.8 + (i * 0.15)  # Cada botón aparece 0.15s después del anterior
		
		entrance_tween.tween_property(button, "modulate:a", 1.0, 0.4).set_delay(delay)
		entrance_tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.6).set_delay(delay)
		entrance_tween.tween_property(button, "rotation", 0.0, 0.5).set_delay(delay)
		entrance_tween.set_ease(Tween.EASE_OUT)
		entrance_tween.set_trans(Tween.TRANS_ELASTIC)
	
	# Animar elementos inferiores
	if character_name_label:
		entrance_tween.tween_property(character_name_label, "modulate:a", 1.0, 0.5).set_delay(1.5)
	
	if start_button:
		entrance_tween.tween_property(start_button, "modulate:a", 1.0, 0.5).set_delay(1.8)
		entrance_tween.tween_property(start_button, "scale", Vector2(1.0, 1.0), 0.6).set_delay(1.8)
		entrance_tween.set_ease(Tween.EASE_OUT)
		entrance_tween.set_trans(Tween.TRANS_BACK)

# Agregar efectos de partículas (opcional - se puede mejorar más)
func create_selection_particles(button: TextureButton):
	# Crear partículas simples con modulate
	var particles_tween = create_tween()
	particles_tween.set_parallel(true)
	
	# Crear varios "destellos" alrededor del botón
	for i in 8:
		var angle = (PI * 2 / 8) * i
		var offset = Vector2(cos(angle), sin(angle)) * 50
		
		# Simular partícula con un pequeño ColorRect
		var particle = ColorRect.new()
		particle.size = Vector2(4, 4)
		particle.color = Color.YELLOW
		particle.position = button.global_position + button.size / 2 + offset
		get_tree().current_scene.add_child(particle)
		
		# Animar la partícula
		particles_tween.tween_property(particle, "modulate:a", 0.0, 0.8)
		particles_tween.tween_property(particle, "scale", Vector2(2.0, 2.0), 0.8)
		
		# Eliminar la partícula después de la animación
		particles_tween.tween_callback(particle.queue_free).set_delay(0.9)