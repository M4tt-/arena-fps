extends MomentumBody3D
class_name PlayerController

@export_group("Movement")
@export var acceleration : float = 100.0 # m/s^2
@export var deceleration : float = 120.0 # m/s^2
@export var move_speed : float = 5.0 # m/s
@export var jump_velocity : float = 4.0 # m/s
@export var air_control := 0.5

@export_group("Jetpack")
@export var jetpack_thrust: float = 18.0  # upward accel in m/s^2-ish
@export var jetpack_max_up_speed: float = 10.0  # clamp vertical speed while thrusting
@export var jetpack_fuel_max: float = 1.5 # s
@export var jetpack_burn_rate: float = 1.0 # Hz
@export var jetpack_recharge_rate: float = 0.75 # Hz
var jetpack_fuel: float

@export_category("References")
@export var camera_controller: Node3D
@export var capsule_shape_node: CollisionShape3D

@onready var state_machine := MovementStateMachine.new()
@onready var grounded_state := GroundedState.new()
@onready var air_state := AirState.new()

@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var camera_pivot: Node3D = $CameraController
@onready var cam: Camera3D = $CameraController/PitchPivot/CameraRig/Boom/Camera3D
@onready var health_bar: Node3D = $UiAnchor/HealthBar   # adjust path

func _physics_process(delta: float) -> void:

	# Let movement/state logic compute desired velocity first
	state_machine.physics_update(delta)

	# Incorporate external impulses
	integrate_external(delta)

	# Apply external for this tick only
	velocity += external_velocity
	move_and_slide()
	velocity -= external_velocity

func update_rotation(rotation_input) -> void:
	global_transform.basis = Basis.from_euler(rotation_input)

func _enter_tree() -> void:
	add_to_group("player")
	print("PlayerController entered tree. groups=", get_groups())
	print("Nodes in 'player' group now: ", get_tree().get_nodes_in_group("player"))

func _ready() -> void:
	# Autowire
	if camera_controller == null: camera_controller = $CameraController
	if capsule_shape_node == null: capsule_shape_node = $CollisionShape3D
	#add_to_group("player")

	add_child(state_machine)

	# Wire states
	grounded_state.player = self
	grounded_state.state_machine = state_machine

	air_state.player = self
	air_state.state_machine = state_machine

	# Initial state
	state_machine.change_state(grounded_state)

	# Init jetpack
	jetpack_fuel = jetpack_fuel_max

	# If this player's camera is the one being used, hide the bar.
	if cam and cam.current:
		health_bar.visible = false

func update_jetpack_fuel(delta: float, is_jetpack_pressed: bool) -> void:
	if is_jetpack_pressed:
		jetpack_fuel = maxf(0.0, jetpack_fuel - jetpack_burn_rate * delta)
	else:
		jetpack_fuel = minf(jetpack_fuel_max, jetpack_fuel + jetpack_recharge_rate * delta)

func can_jetpack() -> bool:
	return jetpack_fuel > 0.0

func apply_jetpack(delta: float) -> void:
	if jetpack_fuel <= 0.0:
		return

	# Apply upward thrust as acceleration
	velocity.y += jetpack_thrust * delta

	# Clamp upward velocity so it doesn't go infinite
	velocity.y = minf(velocity.y, jetpack_max_up_speed)

func handle_ground_movement(delta: float) -> void:
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var wish_dir := (global_transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)).normalized()

	var horiz := Vector3(velocity.x, 0.0, velocity.z)
	var target := wish_dir * move_speed

	var rate := acceleration if wish_dir != Vector3.ZERO else deceleration
	horiz = horiz.move_toward(target, rate * delta)

	velocity.x = horiz.x
	velocity.z = horiz.z

func handle_air_movement(delta: float) -> void:
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var wish_dir := (global_transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)).normalized()

	var horiz := Vector3(velocity.x, 0.0, velocity.z)
	var target := wish_dir * move_speed

	horiz = horiz.move_toward(target, air_control * move_speed * delta)

	velocity.x = horiz.x
	velocity.z = horiz.z
