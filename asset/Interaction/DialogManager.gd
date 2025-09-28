extends Node

@onready var text_box_scene = preload("res://asset/Text Box/text_box.tscn")

var dialog_lines: Array[String] = []
var current_line_index = 0

var text_box
var text_box_position: Vector2
var current_asset_type = ""

var is_dialog_active = false
var can_advance_line = false

func start_dialog(position: Vector2, lines: Array[String], asset_type: String = ""):
	if is_dialog_active:
		return
	
	dialog_lines = lines
	text_box_position = position
	current_asset_type = asset_type
	_show_text_box()
	
	is_dialog_active = true

func _show_text_box():
	text_box = text_box_scene.instantiate()
	text_box.finished_displaying.connect(_on_text_box_finished_displaying)
	
	# Set the asset type for safety tips
	if current_asset_type != "":
		text_box.current_asset_type = current_asset_type
		print("Setting asset type to text box: ", current_asset_type)  # Debug print
	
	get_tree().root.add_child(text_box)
	text_box.global_position = text_box_position
	text_box.display_text(dialog_lines[current_line_index])
	can_advance_line = false

func _on_text_box_finished_displaying():
	can_advance_line = true

func _unhandled_input(event):
	if (
		event.is_action_pressed("advance_dialog") &&
		is_dialog_active &&
		can_advance_line
	):
		text_box.queue_free()
		
		current_line_index += 1
		if current_line_index >= dialog_lines.size():
			is_dialog_active = false
			current_line_index = 0
		else:
			_show_text_box()
