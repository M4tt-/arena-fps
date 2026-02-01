# Artificial enemies that display primitive movement patterns

extends MomentumBody3D
class_name Enemy

enum Behavior { STATIC, HOVER, HOVER_STRAFE }

@export var behavior: Behavior = Behavior.STATIC

@export_group("Hover (Jetpack)")
@export var hover_amplitude: float = 2.0 # m
@export var hover_period: float = 2.0   # seconds per cycle

@export_group("Strafe (Left/Right)")
@export var strafe_distance: float = 6.0  # m
@export var strafe_period: float = 3.0   # s

@export_group("Movement")
@export var gravity_scale: float = 1.0 # 0 for “jetpack floats”; >0 for falling feel
@export var ground_friction: float = 20.0 # only relevant if you enable gravity and touch ground

@export_group("Respawn")
@export var respawn_enabled: bool = true
@export var respawn_delay: float = 2.0

@onready var health: Health = _find_health_direct()
@onready var collision_shape: CollisionShape3D = find_child("CollisionShape3D", true, false) as CollisionShape3D

var _spawn_pos: Vector3
var _dead: bool = false

var _t: float = 0.0
var _start_pos: Vector3

func _ready() -> void:
	_start_pos = global_position
	_spawn_pos = global_position

	if health:
		health.died.connect(_on_died)
	else:
		push_error("%s: Enemy has no Health node" % get_path())

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
	integrate_external(delta)
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

func _on_died() -> void:
	if _dead:
		return
	_dead = true

	_set_alive(false)

	if respawn_enabled:
		await get_tree().create_timer(respawn_delay).timeout
		_respawn()

func _respawn() -> void:
	# Teleport to original spawn
	global_position = _spawn_pos
	velocity = Vector3.ZERO
	external_velocity = Vector3.ZERO  # MomentumBody3D field (you use it)

	# Reset movement phase so hover/strafe restarts cleanly
	_t = 0.0
	_start_pos = global_position

	# Restore health
	if health:
		health.reset_full()

	_set_alive(true)
	_dead = false

func _set_alive(alive: bool) -> void:
	# Hide/show entire enemy (includes HealthBar, mesh, etc.)
	visible = alive

	# Disable collisions so dead enemies don't block shots
	if collision_shape:
		collision_shape.disabled = not alive

	# Stop movement while dead
	set_physics_process(alive)
	set_process(alive)

func _find_health_direct() -> Health:
	# Prefer direct child Health
	for c in get_children():
		if c is Health:
			return c

	# If you store stuff under Components, allow one level down
	var comps := find_child("Components", false, false)
	if comps:
		for c in comps.get_children():
			if c is Health:
				return c

	return null
