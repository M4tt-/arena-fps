extends Node
class_name Shooter

@export_category("Shooting Settings")
@export var projectile_scene: PackedScene
@export var projectile_data: ProjectileData
@export var fire_rate: float = 4.0 # Hz
@export var muzzle_distance: float = 0.7 # m
@export var inherit_factor_override: float = -1.0  # -1 means "use data.inherit_factor"

@export_category("References")
@export var player: CharacterBody3D
@export var camera: Camera3D

var _cooldown: float = 0.0

func _physics_process(delta: float) -> void:
	_cooldown = maxf(0.0, _cooldown - delta)

	if Input.is_action_pressed("fire") and _cooldown <= 0.0:
		_fire()
		_cooldown = 1.0 / fire_rate

func _fire() -> void:
	if projectile_scene == null:
		push_warning("Shooter: projectile_scene not set")
		return
	if projectile_data == null:
		push_warning("Shooter: projectile_data not set")
		return
	if player == null or camera == null:
		push_warning("Shooter: player/camera not set")
		return

	var proj := projectile_scene.instantiate() as Projectile
	if proj == null:
		push_warning("Shooter: projectile_scene root is not a Projectile")
		return

	proj.data = projectile_data

	var forward := -camera.global_transform.basis.z
	var origin := camera.global_transform.origin + forward * muzzle_distance

	var inherit_factor := projectile_data.inherit_factor
	if inherit_factor_override >= 0.0:
		inherit_factor = inherit_factor_override

	# Add to world (not player)
	get_tree().current_scene.add_child(proj)

	proj.initialize(origin, forward, player.velocity * inherit_factor)
