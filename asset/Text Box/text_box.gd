extends NinePatchRect

@onready var label = $MarginContainer/Label
@onready var timer = $Timer
@onready var auto_hide_timer = $AutoHideTimer

const MIN_WIDTH = 120
const MAX_WIDTH = 400
const PADDING = 32  # Extra padding for comfortable reading
const AUTO_HIDE_TIME = 2.0  # Time in seconds before auto-hide

var text = ""
var letter_index = 0

var letter_time = 0.03
var space_time = 0.06
var punctuation_time = 0.2

signal finished_displaying()

func display_text(text_to_display: String):
	text = text_to_display
	
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
	
	var optimal_width = clamp(text_width + PADDING, MIN_WIDTH, MAX_WIDTH)
	
	# Set the size
	custom_minimum_size.x = optimal_width
	size.x = optimal_width
	
	# Enable word wrap if text exceeds maximum width
	if text_width + PADDING > MAX_WIDTH:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD
		await get_tree().process_frame
		custom_minimum_size.y = label.size.y + 16  # Add some vertical padding
		size.y = custom_minimum_size.y
	else:
		label.autowrap_mode = TextServer.AUTOWRAP_OFF
		custom_minimum_size.y = 0  # Let it auto-size
	
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
		# Start auto-hide timer after text is fully displayed
		if auto_hide_timer:  # Add null check
			auto_hide_timer.start(AUTO_HIDE_TIME)
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
	queue_free()  # Hide the text box by removing it from the scene
