extends StaticBody2D

@onready var interaction_area = $InteractionArea
@onready var animated_sprite = $CharacterBody2D/AnimatedSprite2D

const lines: Array[String] = [
	"Turning on electric fan!",
	"Electric fans are useful in emergencies:",
	"• Provide cooling and air circulation",
	"• Help with ventilation to clear smoke",
	"• Can be powered by generators or power banks",
	"• Essential for comfort during power outages"
]

func _ready():
	interaction_area.interact = Callable(self, "_on_interact")
	interaction_area.action_name = "examine"

func _on_interact():
	# Safety check for overlapping bodies
	var overlapping_bodies = interaction_area.get_overlapping_bodies()
	if overlapping_bodies.size() > 0:
		# Start the fan animation
		animated_sprite.play("default")
		
		# Use the new DialogManager autoload
		var dialog_position = global_position + Vector2(0, -50)  # Position dialog above fan
		DialogManager.start_dialog(dialog_position, lines)
