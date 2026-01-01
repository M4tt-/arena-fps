extends CharacterBody3D
class_name Enemy

enum Behavior { STATIC, HOVER, HOVER_STRAFE }

@export var behavior: Behavior = Behavior.STATIC
@export var mass: float = 100

@export_group("Hover (Jetpack)")
@export var hover_amplitude: float = 2.0      # meters up/down
@export var hover_period: float = 2.0         # seconds per cycle

@export_group("Strafe (Left/Right)")
@export var strafe_distance: float = 6.0      # meters left/right from start
@export var strafe_period: float = 3.0        # seconds for left->right->left

@export_group("Movement")
@export var gravity_scale: float = 1.0        # 0 for “jetpack floats”; >0 for falling feel
@export var ground_friction: float = 20.0     # only relevant if you enable gravity and touch ground

@export_group("Impact Response")
@export var impact_drag: float = 6.0       # higher = knockback dies faster
@export var max_impact_speed: float = 25.0     # clamp so it never gets silly

var external_velocity: Vector3 = Vector3.ZERO
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
			pass

		Behavior.HOVER:
			_apply_hover_only(delta)

		Behavior.HOVER_STRAFE:
			_apply_hover_and_strafe(delta)

	# Include velocity from collisions
	external_velocity *= exp(-impact_drag * delta)
	velocity += external_velocity
	move_and_slide()
	velocity -= external_velocity

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

func apply_external_impulse(delta_v: Vector3) -> void:
	# delta_v is change in velocity, not force
	external_velocity += delta_v
	external_velocity = external_velocity.limit_length(max_impact_speed)
