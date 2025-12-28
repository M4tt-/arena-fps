class_name GroundedState extends MovementState

func enter() -> void:
	pass

func physics_update(delta: float) -> void:
	# Gravity only if not grounded (edge cases)
	if not player.is_on_floor():
		state_machine.change_state(player.air_state)
		return

	# Fuel updates regardless of state
	var jetpack_pressed := Input.is_action_pressed("jetpack")
	player.update_jetpack_fuel(delta, jetpack_pressed)

	# Jump
	if Input.is_action_just_pressed("jump"):
		player.velocity.y = player.jump_velocity
		state_machine.change_state(player.air_state)
		return

	# Ground movement
	player.handle_ground_movement(delta)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
