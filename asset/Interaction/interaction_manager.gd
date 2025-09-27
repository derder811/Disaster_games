extends Node2D

# Get player from group "Player"
@onready var player = get_tree().get_first_node_in_group("Player2")

# Store label reference
@onready var label = $Label

# Constants
const BASE_TEXT = "Press (E) to  "

# Variables
var active_areas: Array = []
var can_interact = true

func _ready():
	print("=== InteractionManager _ready() ===")
	print("InteractionManager ready. Player found: ", player != null)
	if player:
		print("Player position: ", player.global_position)
		print("Player groups: ", player.get_groups())
		print("Player collision_layer: ", player.collision_layer)
		print("Player collision_mask: ", player.collision_mask)
	else:
		print("ERROR: Player not found in Player2 group!")
	print("Label reference: ", label != null)
	if label:
		print("Label initial position: ", label.global_position)
		print("Label initial visibility: ", label.visible)
	print("=== End InteractionManager _ready() ===")

# Functions
func register_area(area: InteractionArea):
	print("=== InteractionManager: REGISTERING AREA ===")
	print("Area name: ", area.action_name)
	print("Area position: ", area.global_position)
	print("Current active areas count: ", active_areas.size())
	active_areas.append(area)
	print("New active areas count: ", active_areas.size())
	print("=== End register area ===")

func unregister_area(area: InteractionArea):
	print("=== InteractionManager: UNREGISTERING AREA ===")
	print("Area name: ", area.action_name)
	print("Current active areas count: ", active_areas.size())
	var index = active_areas.find(area)
	if index != -1:
		active_areas.remove_at(index)
		print("Area removed. New count: ", active_areas.size())
	else:
		print("ERROR: Area not found in active_areas!")
	print("=== End unregister area ===")

func sort_by_distance_to_player(a, b):
	var distance_a = player.global_position.distance_to(a.global_position)
	var distance_b = player.global_position.distance_to(b.global_position)
	return distance_a < distance_b

func _process(delta):
	if active_areas.size() > 0 and can_interact:
		# Sort by distance
		active_areas.sort_custom(sort_by_distance_to_player)
		
		# Show label above closest area
		var closest_area = active_areas[0]
		label.text = BASE_TEXT + closest_area.action_name
		label.visible = true
		label.global_position = closest_area.global_position + Vector2(0, -50)
		
		# Only print occasionally to avoid spam
		if Engine.get_process_frames() % 60 == 0:  # Every 60 frames (1 second at 60fps)
			print("InteractionManager: Showing label - '", label.text, "' at position: ", label.global_position)
			print("Closest area: ", closest_area.action_name, " at ", closest_area.global_position)
	else:
		# Hide label
		if label.visible:
			print("InteractionManager: Hiding label (active_areas: ", active_areas.size(), ", can_interact: ", can_interact, ")")
		label.visible = false

func _input(event):
	if event.is_action_pressed("interact") and can_interact:
		if active_areas.size() > 0:
			print("InteractionManager: Interact pressed, calling interact on: ", active_areas[0].action_name)
			can_interact = false
			label.visible = false
			await active_areas[0].interact.call()
			can_interact = true
