class_name AirState extends MovementState

func enter() -> void:
	pass

func physics_update(delta: float) -> void:
	# Gravity always applies
	player.velocity += player.get_gravity() * delta

	var jetpack_pressed := Input.is_action_pressed("jetpack")

	# Fuel updates regardless of state
	player.update_jetpack_fuel(delta, jetpack_pressed)

	# Jetpack thrust (hold)
	if jetpack_pressed and player.can_jetpack():
		player.apply_jetpack(delta)

	# Air control
	player.handle_air_movement(delta)

	# Land
	if player.is_on_floor():
		state_machine.change_state(player.grounded_state)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
