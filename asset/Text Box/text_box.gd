extends NinePatchRect

@onready var label = $MarginContainer/Label
@onready var timer = $Timer
@onready var auto_hide_timer = $AutoHideTimer
@onready var continue_label = $ContinueLabel

const MIN_WIDTH = 200
const MAX_WIDTH = 600
const PADDING = 32  # Extra padding for comfortable reading

var text = ""
var letter_index = 0
var is_text_complete = false

var letter_time = 0.02
var space_time = 0.04
var punctuation_time = 0.15

# Safety tips for different assets
var safety_tips = {
	"e_fan": [
		"ELECTRICAL SAFETY TIPS:",
		"• Check cords for damage before use",
		"• Keep electrical devices away from water",
		"• Don't overload electrical outlets",
		"• Have backup power sources ready",
		"• Know how to shut off main electrical breaker"
	] as Array[String],
	"bucket": [
		"WATER SAFETY TIPS:",
		"• Store clean water in covered containers",
		"• Boil water if unsure of its safety",
		"• Keep emergency water supplies (1 gallon per person per day)",
		"• Know location of main water shut-off valve",
		"• Have water purification tablets ready"
	] as Array[String],
	"frying_pan": [
		"COOKING SAFETY TIPS:",
		"• Never leave cooking unattended",
		"• Keep pot handles turned inward",
		"• Have a fire extinguisher nearby",
		"• Know how to turn off gas/electricity quickly",
		"• Keep flammable items away from heat sources"
	] as Array[String]
}

var current_asset_type = ""

signal finished_displaying()

func _ready():
	set_process_input(true)
	if continue_label:
		continue_label.visible = false

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_SPACE and is_text_complete:
			# Show safety tips dialog after text interaction
			_show_safety_tips_dialog()

func _show_safety_tips_dialog():
	print("Current asset type: ", current_asset_type)  # Debug print
	
	# Find the DialogBox node in the scene
	var dialog_box = get_tree().get_first_node_in_group("dialog_system")
	if dialog_box and dialog_box.has_method("show_dialog"):
		var tips: Array[String] = safety_tips.get(current_asset_type, ["No safety tips available for this item."] as Array[String])
		print("Safety tips found: ", tips)  # Debug print
		dialog_box.show_dialog("SAFETY TIPS", tips)
	else:
		print("DialogBox not found or doesn't have show_dialog method")
	
	# Close the text box after showing safety tips
	queue_free()

func display_text(text_to_display: String):
	text = text_to_display
	is_text_complete = false
	
	# Hide continue label initially
	if continue_label:
		continue_label.visible = false
	
	# Set text temporarily to measure size
	label.text = text_to_display
	label.autowrap_mode = TextServer.AUTOWRAP_OFF
	
	# Force update to get accurate size
	await get_tree().process_frame
	
	# Calculate optimal width based on label size
	var text_width = label.get_theme_font("font").get_string_size(
		text_to_display, 
		HORIZONTAL_ALIGNMENT_LEFT, 
		-1, 
		label.get_theme_font_size("font_size")
	).x
	
	var optimal_width = text_width + PADDING * 2
	optimal_width = clamp(optimal_width, MIN_WIDTH, MAX_WIDTH)
	
	# Set the size
	custom_minimum_size.x = optimal_width
	size.x = optimal_width
	
	# Enable word wrap and set proper sizing
	label.autowrap_mode = TextServer.AUTOWRAP_WORD
	await get_tree().process_frame
	custom_minimum_size.y = label.size.y + 24  # Add vertical padding
	
	# Position the dialog box
	global_position.x -= size.x / 2
	global_position.y -= size.y + 24
	
	# Clear text and start letter-by-letter display
	label.text = ""
	letter_index = 0
	_display_letter()

func _display_letter():
	label.text += text[letter_index]
	
	letter_index += 1
	if letter_index >= text.length():
		finished_displaying.emit()
		is_text_complete = true
		# Show continue label when text is complete
		if continue_label:
			continue_label.visible = true
		# Auto-hide timer removed - text box will only close on spacebar press
		return
	
	match text[letter_index]:
		"!", ".", ",", "?":
			if timer:  # Add null check
				timer.start(punctuation_time)
		" ":
			if timer:  # Add null check
				timer.start(space_time)
		_:
			if timer:  # Add null check
				timer.start(letter_time)
			

func _on_timer_timeout() -> void:
	_display_letter()

func _on_auto_hide_timer_timeout() -> void:
	# Auto-hide functionality removed - this function is no longer used
	pass
