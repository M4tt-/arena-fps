# This is "totally inelastic" in gameplay terms: projectile does not bounce and does not retain momentum.

extends MomentumBody3D
class_name MomentumProjectileBody

@export_category("Projectile Momentum")
@export var destroy_on_hit: bool = true
@export var impart_scale: float = 1.0      # tune knockback strength
@export var max_hits: int = 1              # 1 = die on first hit; >1 allows piercing

var _hits: int = 0

func impart_momentum_on_collision(collision: KinematicCollision3D) -> void:
	var collider := collision.get_collider()
	if collider is MomentumBody3D:
		var target := collider as MomentumBody3D

		# Projectile momentum p = m * v
		var p : Vector3 = mass * total_velocity()

		# Transfer momentum to target as a delta-v: Δv = p / m_target
		var dv_target : Vector3 = (p / max(target.mass, 0.001)) * impart_scale
		target.apply_external_impulse(dv_target)

	_hits += 1
	if destroy_on_hit and _hits >= max_hits:
		queue_free()
