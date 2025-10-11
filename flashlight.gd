extends Area2D

@export var itemName: String = "Flashlight"
@export var itemIcon: Texture2D

var itemData: Dictionary

func _ready():
	# Use the texture from the Sprite2D if itemIcon is not set
	if itemIcon:
		$Sprite2D.texture = itemIcon
	else:
		itemIcon = $Sprite2D.texture
	
	itemData = {
		"name": itemName,
		"icon": itemIcon
	}
	
	print("Item '", itemName, "' initialized at position: ", global_position)

func _on_body_entered(body):
	print("=== COLLISION DETECTED ===")
	print("Item '", itemName, "' detected collision with: ", body.name)
	print("Body type: ", body.get_class())
	print("Body groups: ", body.get_groups())
	print("Checking if 'Player' in body.name: ", "Player" in body.name)
	print("Checking if body is in group 'Player2': ", body.is_in_group("Player2"))
	
	if "Player" in body.name or body.is_in_group("Player2"):
		print("✓ Player detected! Calling get_items...")
		if body.has_method("get_items"):
			body.get_items(itemData)
			print("✓ Item '", itemName, "' picked up successfully!")
			queue_free()
		else:
			print("✗ ERROR: Body doesn't have get_items method!")
	else:
		print("✗ Not a player, ignoring collision")