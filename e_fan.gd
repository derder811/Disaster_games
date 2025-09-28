extends StaticBody2D

@onready var interaction_area = $InteractionArea
@onready var animated_sprite = $CharacterBody2D/AnimatedSprite2D

const lines: Array[String] = [
	"Electric Fan Safety Tips:",
	"• Always turn off the fan before cleaning or maintenance",
	"• Keep the fan away from water and moisture",
	"• Check the power cord regularly for damage",
	"• Don't insert objects into the fan blades",
	"• Ensure proper ventilation around the fan",
	"• Unplug during thunderstorms to prevent electrical damage",
	"• Keep children away from moving fan blades",
	"Fan turned off safely!"
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
		
		# Use DialogManager with asset type to show safety tips
		var dialog_position = global_position + Vector2(0, -50)  # Position dialog above fan
		DialogManager.start_dialog(dialog_position, lines, "e_fan")
		
		# Complete the quest objective for e_fan interaction
		var quest_node = get_node("../Quest")
		if quest_node and quest_node.has_method("on_efan_interaction"):
			quest_node.on_efan_interaction()
			print("E-Fan: Quest objective completed!")
