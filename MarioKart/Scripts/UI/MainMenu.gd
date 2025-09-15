# MainMenu.gd
extends Control

@onready var title_label = $UI/TitleLabel
@onready var start_button = $UI/StartButton
@onready var quit_button = $UI/QuitButton
@onready var background = $Background

var button_tween : Tween

func _ready():
	print("=== MENÚ PRINCIPAL CARGADO ===")
	setup_menu()
	animate_title()

func setup_menu():
	# Configurar botones
	if start_button:
		start_button.pressed.connect(_on_start_pressed)
		start_button.mouse_entered.connect(_on_button_hover.bind(start_button))
		start_button.mouse_exited.connect(_on_button_unhover.bind(start_button))
	
	if quit_button:
		quit_button.pressed.connect(_on_quit_pressed)
		quit_button.mouse_entered.connect(_on_button_hover.bind(quit_button))
		quit_button.mouse_exited.connect(_on_button_unhover.bind(quit_button))

func animate_title():
	if title_label:
		var title_tween = create_tween()
		title_tween.set_loops()
		title_tween.tween_property(title_label, "modulate", Color(1.2, 1.2, 1.2, 1.0), 1.0)
		title_tween.tween_property(title_label, "modulate", Color(1.0, 1.0, 1.0, 1.0), 1.0)

func _on_start_pressed():
	print("🎮 Iniciando selector de personajes...")
	get_tree().change_scene_to_file("res://Scenes/SelectorPersonajes.tscn")

func _on_quit_pressed():
	print("👋 Saliendo del juego...")
	get_tree().quit()

func _on_button_hover(button: Button):
	if button_tween:
		button_tween.kill()
	
	button_tween = create_tween()
	button_tween.tween_property(button, "scale", Vector2(1.1, 1.1), 0.2)

func _on_button_unhover(button: Button):
	if button_tween:
		button_tween.kill()
	
	button_tween = create_tween()
	button_tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.2)

func _input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_ENTER:
				_on_start_pressed()
			KEY_ESCAPE:
				_on_quit_pressed()