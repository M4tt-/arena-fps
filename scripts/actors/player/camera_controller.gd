class_name CameraController extends Node3D

@export var debug : bool = false
@export_category("References")
@export var player_controller : PlayerController
@export var component_mouse_capture : MouseCaptureComponent
@export_category("Camera Settings")
@export_group("Camera Tilt")
@export_range(-90, -60) var tilt_lower_limit : int = -90 # deg
@export_range(60, 90) var tilt_upper_limit : int = 90 # deg

var _rotation : Vector3

func _physics_process(delta: float) -> void:
	if component_mouse_capture == null:
		return

	var look := component_mouse_capture.get_mouse_input()
	if look != Vector2.ZERO:
		update_camera_rotation(look)
		component_mouse_capture.clear_mouse_input()

func update_camera_rotation(input: Vector2) -> void:
	_rotation.x += input.y
	_rotation.y += input.x
	_rotation.x = clamp(_rotation.x, deg_to_rad(tilt_lower_limit), deg_to_rad(tilt_upper_limit))

	var _player_rotation = Vector3(0.0, _rotation.y, 0.0)
	var _camera_rotation = Vector3(_rotation.x, 0.0, 0.0)

	transform.basis = Basis.from_euler(_camera_rotation)
	player_controller.update_rotation(_player_rotation)
	rotation.z = 0.0
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_rotation = Vector3.ZERO
