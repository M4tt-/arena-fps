class_name CameraController extends Node3D

@export var player_controller: PlayerController
@export var component_mouse_capture: MouseCaptureComponent

@export_category("Camera Nodes")
@export var pitch_pivot: Node3D # PitchPivot node represents bending at neck for pitch
@export var camera_rig: Node3D
@export var boom: SpringArm3D
@export var camera: Camera3D

@export_range(-90, -60) var tilt_lower_limit: int = -90
@export_range(60, 90) var tilt_upper_limit: int = 90

enum ViewMode { FIRST_PERSON, THIRD_PERSON }
@export var view_mode: ViewMode = ViewMode.FIRST_PERSON

@export var head_height: float = 1.6

@export var tp_distance: float = 3.0
@export var tp_shoulder: float = 0.35
@export var tp_pitch_bias_deg: float = -2.0

var _rotation := Vector3.ZERO

func _ready() -> void:
	_rotation = Vector3.ZERO

	# Head height belongs on the pivot that rotates
	if pitch_pivot:
		pitch_pivot.position = Vector3(0.0, head_height, 0.0)

	_apply_view_mode()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_third_person"):
		toggle_view_mode()

func _physics_process(delta: float) -> void:
	if component_mouse_capture == null:
		return

	var look := component_mouse_capture.get_mouse_input()
	if look != Vector2.ZERO:
		update_camera_rotation(look)
		component_mouse_capture.clear_mouse_input()

func toggle_view_mode() -> void:
	view_mode = ViewMode.THIRD_PERSON if view_mode == ViewMode.FIRST_PERSON else ViewMode.FIRST_PERSON
	_apply_view_mode()

func set_view_mode(mode: ViewMode) -> void:
	view_mode = mode
	_apply_view_mode()

func update_camera_rotation(input: Vector2) -> void:
	_rotation.x += input.y
	_rotation.y += input.x
	_rotation.x = clamp(_rotation.x, deg_to_rad(tilt_lower_limit), deg_to_rad(tilt_upper_limit))

	# Yaw to player (unchanged)
	player_controller.update_rotation(Vector3(0.0, _rotation.y, 0.0))

	# Pitch to PitchPivot (NEW)
	var pitch_bias := deg_to_rad(tp_pitch_bias_deg) if view_mode == ViewMode.THIRD_PERSON else 0.0
	var pitch := _rotation.x + pitch_bias
	if pitch_pivot:
		pitch_pivot.rotation.x = pitch
		pitch_pivot.rotation.z = 0.0
	else:
		push_error("PitchPivot not set in CameraController.")

func _apply_view_mode() -> void:
	if camera_rig == null or camera == null:
		return

	var is_tp := view_mode == ViewMode.THIRD_PERSON

	# In FPS, rig stays at origin so pitch does not induce translation
	camera_rig.position = Vector3(tp_shoulder, 0.0, 0.0) if is_tp else Vector3.ZERO

	if boom:
		boom.spring_length = tp_distance if is_tp else 0.0
		camera.position = Vector3.ZERO
	else:
		camera.position = Vector3(0.0, 0.0, -tp_distance) if is_tp else Vector3.ZERO
