#CharacterManager.gd
extends Node
class_name CharacterManager

# Manages character selection and instantiation
# Simplified to work directly with Racer subclasses

enum CharacterType {
	MARIO,
	LUIGI,
	PEACH,
	YOSHI,
	TOAD
}

# Character data structure
class CharacterData:
	var name: String
	var script_path: String
	var sprite_frames_path: String
	var sound_effects_path: String
	
	func _init(n: String, s: String, sf: String, se: String):
		name = n
		script_path = s
		sprite_frames_path = sf
		sound_effects_path = se

# Character database - easy to extend with new characters
var character_database = {
	CharacterType.MARIO: CharacterData.new(
		"Mario",
		"res://Scripts/World Elements/Racers/Mario.gd",
		"res://path/to/mario_sprite_frames.tres",
		"res://path/to/mario_sounds.tres"
	),
	CharacterType.LUIGI: CharacterData.new(
		"Luigi", 
		"res://Scripts/World Elements/Racers/Luigi.gd",
		"res://path/to/luigi_sprite_frames.tres",
		"res://path/to/luigi_sounds.tres"
	)
	# Add more characters here easily:
	# CharacterType.PEACH: CharacterData.new(...),
	# CharacterType.YOSHI: CharacterData.new(...),
	# etc.
}

# Currently selected character
var current_character: CharacterType = CharacterType.MARIO

func get_character_data(character_type: CharacterType) -> CharacterData:
	return character_database.get(character_type)

func set_current_character(character_type: CharacterType):
	current_character = character_type

func get_current_character() -> CharacterType:
	return current_character

func get_character_names() -> Array[String]:
	var names: Array[String] = []
	for character_data in character_database.values():
		names.append(character_data.name)
	return names

# Example function to create a character node (returns Racer)
func create_character_node(character_type: CharacterType) -> Racer:
	var character_data = get_character_data(character_type)
	if not character_data:
		print("Character data not found for type: ", character_type)
		return null
	
	# Load the character script
	var character_script = load(character_data.script_path)
	if not character_script:
		print("Failed to load character script: ", character_data.script_path)
		return null
	
	# Create the character node
	var character_node = Node2D.new()
	character_node.set_script(character_script)
	character_node.name = character_data.name
	
	return character_node as Racer