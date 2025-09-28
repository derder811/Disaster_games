extends StaticBody2D

@onready var interaction_area = $InteractionArea
@onready var sprite = $Sprite2D

const lines: Array[String] = [
	"This is a comfortable bed - essential for rest!",
	"In an emergency, you can use it to:",
	"• Get proper rest to maintain energy",
	"• Stay warm with blankets and pillows",
	"• Create a safe sleeping area",
	"• Use bedding for makeshift shelter",
	
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
		var dialog_position = global_position + Vector2(0, -50)  # Position dialog above bed
		await DialogManager.start_dialog(dialog_position, lines)
		
		# Complete the quest objective for bed interaction
		var quest_node = get_node("../Quest")
		if quest_node and quest_node.has_method("on_bed_interaction"):
			quest_node.on_bed_interaction()
			print("Bed: Quest objective completed!")
