class_name CameraController extends Node3D

@export var debug : bool = false
@export_category("References")
@export var player_controller : PlayerController
@export var component_mouse_capture : MouseCaptureComponent

@export_category("Camera Nodes")
@export var camera_rig : Node3D   # positional offsets live here
@export var boom : SpringArm3D    # for wall clipping avoidance
@export var camera : Camera3D     # the actual camera

@export_category("Camera Settings")
@export_group("Camera Tilt")
@export_range(-90, -60) var tilt_lower_limit : int = -90 # deg
@export_range(60, 90) var tilt_upper_limit : int = 90 # deg


@export_group("View Mode")
enum ViewMode { FIRST_PERSON, THIRD_PERSON }
@export var view_mode : ViewMode = ViewMode.FIRST_PERSON

@export_group("First Person")
@export var fp_rig_offset := Vector3(0.0, 1.6, 0.0)  # where the camera rig sits (head height)
@export var fp_camera_local := Vector3(0.0, 0.0, 0.0)  # camera relative to rig

@export_group("Third Person")
@export var tp_rig_offset := Vector3(0.0, 1.7, 0.0)   # slightly higher is often nicer
@export var tp_distance : float = 3.0
@export var tp_shoulder : float = 0.35                # right shoulder; set 0 for centered
@export var tp_pitch_bias_deg : float = -2.0          # tiny downward bias to keep aim comfy


var _rotation : Vector3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_rotation = Vector3.ZERO
	_apply_view_mode()

func _physics_process(delta: float) -> void:
	if component_mouse_capture == null:
		return

	var look := component_mouse_capture.get_mouse_input()
	if look != Vector2.ZERO:
		update_camera_rotation(look)
		component_mouse_capture.clear_mouse_input()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_third_person"):
		toggle_view_mode()

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

	# Yaw
	var _player_rotation = Vector3(0.0, _rotation.y, 0.0)
	player_controller.update_rotation(_player_rotation)
	
	# Pitch stays on this node, with an optional tiny bias in 3P
	var pitch_bias := deg_to_rad(tp_pitch_bias_deg) if view_mode == ViewMode.THIRD_PERSON else 0.0
	var _camera_rotation = Vector3(_rotation.x + pitch_bias, 0.0, 0.0)

	transform.basis = Basis.from_euler(_camera_rotation)
	rotation.z = 0.0

func _apply_view_mode() -> void:
	if camera_rig == null or camera == null:
		return

	var is_tp := view_mode == ViewMode.THIRD_PERSON

	# Move the rig (height/overall offset from player)
	camera_rig.position = tp_rig_offset if is_tp else fp_rig_offset

	if boom:
		# SpringArm mode: distance handled by spring length; shoulder handled by boom position
		boom.position = Vector3(tp_shoulder, 0.0, 0.0) if is_tp else Vector3.ZERO
		boom.spring_length = tp_distance if is_tp else 0.0
		camera.position = Vector3.ZERO if is_tp else fp_camera_local
	else:
		# No SpringArm: camera sits behind rig directly
		camera.position = Vector3(tp_shoulder, 0.0, -tp_distance) if is_tp else fp_camera_local
