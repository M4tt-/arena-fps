class_name MovementStateMachine extends Node

var current_state: MovementState = null

func change_state(new_state: MovementState) -> void:
	if current_state == new_state:
		return

	if current_state:
		current_state.exit()

	current_state = new_state

	# May disallow in the future if we always want a defined state
	if current_state:
		current_state.enter()
	else:
		print("Transitioning to null state")

func physics_update(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
