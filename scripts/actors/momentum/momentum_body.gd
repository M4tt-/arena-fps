# Base class for CharacterBody3D actors that can receive/provide external impulses.
# External impulses are stored separately from "desired velocity" so character controllers
# can remain authoritative while still reacting to collisions / knockback.

extends CharacterBody3D
class_name MomentumBody3D

@export_category("Momentum")
@export var mass: float = 1.0                 # gameplay mass (larger = harder to push)
@export var external_damping: float = 12.0    # higher = impulses decay faster
@export var max_external_speed: float = 100.0 # safety clamp for external velocity

var external_velocity: Vector3 = Vector3.ZERO

func apply_external_impulse(delta_v: Vector3) -> void:
	# delta_v is "change in velocity" (impulse / mass)
	external_velocity += delta_v
	external_velocity = external_velocity.limit_length(max_external_speed)

func integrate_external(delta: float) -> void:
	# Linear decay toward zero
	external_velocity = external_velocity.move_toward(Vector3.ZERO, external_damping * delta)

func total_velocity() -> Vector3:
	return velocity + external_velocity

func begin_move_with_external() -> void:
	# Call right before move_and_slide/move_and_collide so external effects contribute to motion.
	velocity += external_velocity

func end_move_with_external() -> void:
	# Call right after movement so controller code doesn't permanently "bake in" external effects.
	velocity -= external_velocity
