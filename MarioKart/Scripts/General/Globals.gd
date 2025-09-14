#Globals.gd
extends Node

var screenSize : Vector2 = Vector2(480, 360)

# Variable para almacenar el personaje seleccionado
# Opciones disponibles: "Mario", "Luigi", "Bowser", "DonkeyKong"
var selected_character : String = "Mario"  # Cambia este valor para seleccionar diferente personaje

enum RoadType {
	VOID = 0,
	ROAD = 1,
	GRAVEL = 2,
	OFF_ROAD = 3,
	WALL = 4,
	SINK = 5,
	HAZARD = 6
} 
