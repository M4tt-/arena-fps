# Base class for CharacterBody3D actors that can receive/provide external impulses.
# External impulses are stored separately from "desired velocity" so character controllers
# can remain authoritative while still reacting to collisions / knockback.

extends CharacterBody3D
class_name MomentumBody3D

@export_category("Momentum")
@export var mass: float = 100.0 # kg

@export_group("Impact Response")
@export var impact_decay: float = 6.0 # Hz
@export var max_external_speed: float = 100.0 # m/s

var external_velocity: Vector3 = Vector3.ZERO

func apply_external_impulse(delta_v: Vector3) -> void:
	# delta_v is "change in velocity" (impulse / mass)
	external_velocity += delta_v
	external_velocity = external_velocity.limit_length(max_external_speed)

func integrate_external(delta: float) -> void:
	# Linear decay toward zero
	external_velocity *= exp(-impact_decay * delta)
