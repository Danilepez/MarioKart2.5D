# CharacterSelector.gd
extends Control

signal character_selected(character_name: String)

func _ready():
	print("=== CHARACTER SELECTOR INICIADO ===")

func _on_mario_selected():
	print("Mario seleccionado!")
	character_selected.emit("Mario")
	_start_game("Mario")

func _on_luigi_selected():
	print("Luigi seleccionado!")
	character_selected.emit("Luigi")
	_start_game("Luigi")

func _on_bowser_selected():
	print("Bowser seleccionado!")
	character_selected.emit("Bowser")
	_start_game("Bowser")

func _on_donkey_kong_selected():
	print("Donkey Kong seleccionado!")
	character_selected.emit("DonkeyKong")
	_start_game("DonkeyKong")

func _on_yoshi_selected():
	print("Yoshi seleccionado!")
	character_selected.emit("Yoshi")
	_start_game("Yoshi")

func _start_game(character_name: String):
	# Guardar la selección del personaje globalmente
	Globals.selected_character = character_name
	print("Personaje seleccionado guardado: ", Globals.selected_character)
	
	# Cambiar a la escena principal del juego
	get_tree().change_scene_to_file("res://Scenes/main.tscn")