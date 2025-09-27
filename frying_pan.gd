extends StaticBody2D

@onready var interaction_area = $InteractionArea
@onready var sprite = $Sprite2D

const lines: Array[String] = [
	"This is a frying pan - essential for cooking!",
	"In an emergency, you can use it to:",
	"• Cook food over a fire or camp stove",
	"• Boil water for purification",
	"• Signal for help by reflecting sunlight",
	"Always keep cooking equipment clean and ready!"
]

func _ready():
	interaction_area.interact = Callable(self, "_on_interact")
	interaction_area.action_name = "examine"

func _on_interact():
	# Safety check for overlapping bodies
	var overlapping_bodies = interaction_area.get_overlapping_bodies()
	if overlapping_bodies.size() > 0:
		sprite.flip_h = overlapping_bodies[0].global_position.x < global_position.x
		
		# Use the new DialogManager autoload and await completion
		var dialog_position = global_position + Vector2(0, -50)  # Position dialog above frying pan
		await DialogManager.start_dialog(dialog_position, lines)
