extends Node2D

@onready var interaction_area: InteractionArea = $InteractionArea
@onready var sprite = $AnimatedSprite2D
# @onready var speech_sound = preload("res://asset/player/speech.wav")  # Audio file not found

const lines: Array[String] = [
	"Hey there!",
	"Welcome to our disaster preparedness game!",
	"Press SPACE to advance through dialog.",
	"Good luck exploring!"
]

func _ready():
	if interaction_area:
		interaction_area.interact = _on_interact

func _on_interact():
	# Safety check for overlapping bodies
	var overlapping_bodies = interaction_area.get_overlapping_bodies()
	if overlapping_bodies.size() > 0:
		sprite.flip_h = overlapping_bodies[0].global_position.x < global_position.x
		
		# Use the new DialogManager autoload
		var dialog_position = global_position + Vector2(0, -50)  # Position dialog above NPC
		DialogManager.start_dialog(dialog_position, lines)
