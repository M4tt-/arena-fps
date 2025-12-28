extends ProgressBar  # or TextureProgressBar in future

var player: PlayerController

func _ready() -> void:
	print("HUD ready. size=", size, " pos=", position)
	player = get_tree().get_first_node_in_group("player") as PlayerController
	print("HUD found player: ", player)
	if player == null:
		push_error("JetpackFuelHUD: No node in group 'player'. Is PlayerController instanced and in the group?")
		return

	print("Player fuel=", player.jetpack_fuel, " max=", player.jetpack_fuel_max)
	max_value = player.jetpack_fuel_max
	value = player.jetpack_fuel

func _process(_delta: float) -> void:
	# Depending on how the UI is added to the tree with respect to Player, we may need
	# to search for the player again.
	if player == null:
		player = get_tree().get_first_node_in_group("player") as PlayerController
		if player == null:
			return
		# Initialize bar once we have a player
		max_value = player.jetpack_fuel_max
	value = player.jetpack_fuel
