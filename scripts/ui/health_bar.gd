extends Node3D

@export_range(0.0, 1.0, 0.01) var percent: float = 1.0

@onready var fill: MeshInstance3D = $Fill

var _full_width: float

func _ready() -> void:
	# Cache the original width so we can shift as it shrinks.
	# QuadMesh.size.x is the cleanest way if you're using QuadMesh.
	var qm := fill.mesh as QuadMesh
	_full_width = qm.size.x if qm else 1.0

	_apply_percent()

func _process(_delta: float) -> void:
	var cam := get_viewport().get_camera_3d()
	if cam == null:
		print("HealthBar: cam is null")
		return

	# Billboard: match camera orientation so the quad faces it.
	# This avoids look_at degeneracy / edge-on flips.
	global_basis = cam.global_basis

func set_percent(p: float) -> void:
	percent = clamp(p, 0.0, 1.0)
	_apply_percent()

func _apply_percent() -> void:
	# Shrink in X, keep Y/Z the same
	fill.scale.x = percent

	# Move left so it appears to shrink from right-to-left (left edge stays fixed)
	# When scale.x decreases, the center shifts right unless we compensate.
	fill.position.x = -((1.0 - percent) * _full_width * 0.5)
