extends Label

var player: PlayerController

func _process(_delta: float) -> void:
	# Depending on how the UI is added to the tree with respect to Player, we may need
	# to search for the player again.
	if player == null:
		player = get_tree().get_first_node_in_group("player") as PlayerController
		if player == null:
			text = "Player: <not found>"
			return

	var v := player.velocity
	var horizontal_speed := Vector3(v.x, 0.0, v.z).length()
	var full_speed := v.length()

	# After computing horizontal_speed...
	if full_speed > 10.0:
		modulate = Color(1.0, 0.4, 0.4)
	elif full_speed > 4.0:
		modulate = Color(1.0, 1.0, 0.4)
	else:
		modulate = Color(1.0, 1.0, 1.0)

	text = (
		"Velocity:\n"
		+ "  x: %.2f\n" % v.x
		+ "  y: %.2f\n" % v.y
		+ "  z: %.2f\n" % v.z
		+ "Speed:\n"
		+ "  horizontal: %.2f\n" % horizontal_speed
		+ "  full: %.2f" % full_speed
	)
