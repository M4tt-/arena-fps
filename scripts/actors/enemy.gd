extends CharacterBody3D
class_name Enemy

enum Behavior { STATIC, HOVER, HOVER_STRAFE }

@export var behavior: Behavior = Behavior.STATIC

@export_group("Hover (Jetpack)")
@export var hover_amplitude: float = 2.0      # meters up/down
@export var hover_period: float = 2.0         # seconds per cycle

@export_group("Strafe (Left/Right)")
@export var strafe_distance: float = 6.0      # meters left/right from start
@export var strafe_period: float = 3.0        # seconds for left->right->left

@export_group("Movement")
@export var gravity_scale: float = 0.0        # 0 for “jetpack floats”; >0 for falling feel
@export var ground_friction: float = 20.0     # only relevant if you enable gravity and touch ground

var _t: float = 0.0
var _start_pos: Vector3

func _ready() -> void:
	_start_pos = global_position

func _physics_process(delta: float) -> void:
	_t += delta

	# Base gravity if you want it (often 0 for hover bots)
	if gravity_scale != 0.0:
		velocity += get_gravity() * gravity_scale * delta

	match behavior:
		Behavior.STATIC:
			# Stand still (but still collides)
			velocity.x = move_toward(velocity.x, 0.0, ground_friction * delta)
			velocity.z = move_toward(velocity.z, 0.0, ground_friction * delta)

		Behavior.HOVER:
			_apply_hover_only(delta)
			# Damp the other directions
			velocity.x = move_toward(velocity.x, 0.0, ground_friction * delta)
			velocity.z = move_toward(velocity.z, 0.0, ground_friction * delta)

		Behavior.HOVER_STRAFE:
			_apply_hover_and_strafe(delta)
			# Damp the other directions
			velocity.z = move_toward(velocity.z, 0.0, 5 * ground_friction * delta)
	move_and_slide()

func _apply_hover_only(delta: float) -> void:
	# Vertical sinusoid around the start position.
	# This is “jetpack up/down periodically”.
	var omega := TAU / hover_period
	var target_y := _start_pos.y + sin(_t * omega) * hover_amplitude

	# Convert target position into a velocity each tick (simple, stable)
	var y_error := target_y - global_position.y
	velocity.y = y_error / max(delta, 0.001)

func _apply_hover_and_strafe(delta: float) -> void:
	# Hover
	_apply_hover_only(delta)

	# Ping-pong motion: sin() gives smooth turnarounds
	var omega := TAU / strafe_period
	var offset_x := sin(_t * omega) * strafe_distance

	var target_x := _start_pos.x + offset_x
	var x_error := target_x - global_position.x
	velocity.x = x_error / max(delta, 0.001)

	if Engine.get_physics_frames() % 10 == 0:
		print("pos=", global_position, " vel=", velocity, " vel_len=", velocity.length())
