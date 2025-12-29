class_name MouseCaptureComponent extends Node

@export var debug : bool = false
@export_category("Mouse Capture Settings")
@export var current_mouse_mode : Input.MouseMode = Input.MOUSE_MODE_CAPTURED
@export var mouse_sensitivity : float = 0.005

var _capture_mouse : bool
var _mouse_input : Vector2 = Vector2.ZERO

func _unhandled_input(event: InputEvent) -> void:

	# Release mouse / quit controls
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			if event.shift_pressed:
				get_tree().quit()
			else:
				if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
					Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
				else:
					Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			get_viewport().set_input_as_handled()
			return

	_capture_mouse = event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
	if _capture_mouse:
		_mouse_input.x += -event.screen_relative.x * mouse_sensitivity
		_mouse_input.y += -event.screen_relative.y * mouse_sensitivity
	if debug:
		print(_mouse_input)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.mouse_mode = current_mouse_mode

func get_mouse_input() -> Vector2:
	return _mouse_input

func clear_mouse_input() -> void:
	_mouse_input = Vector2.ZERO
