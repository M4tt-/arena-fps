# Adds bilateral momentum exchange between two MomentumCharacterBody3D bodies.
# Uses a normal-impulse model with optional elasticity.

extends MomentumBody3D
class_name MomentumCharacterBody3D

@export_category("Momentum Exchange")
@export_range(0.0, 1.0) var elasticity: float = 0.0  # 0=inelastic shove, 1=fully elastic bounce
@export var impulse_scale: float = 1.0               # reduce if too strong

var _pre_slide_total_velocity: Vector3 = Vector3.ZERO

func capture_pre_slide_velocity() -> void:
	_pre_slide_total_velocity = total_velocity()

func exchange_momentum_after_move() -> void:
	# Call after move_and_slide() in the same physics tick.
	var count := get_slide_collision_count()
	for i in range(count):
		var collision := get_slide_collision(i)
		var collider := collision.get_collider()

		if collider is MomentumCharacterBody3D:
			var self_speed := total_velocity().length()
			var other_speed := (collider as MomentumCharacterBody3D).total_velocity().length()
			if self_speed <= other_speed:
				continue
			_transfer_momentum(collider, collision.get_normal())

func _transfer_momentum(collider: MomentumCharacterBody3D, normal: Vector3) -> void:
	var n : Vector3 = normal.normalized()

	var v_self := _pre_slide_total_velocity
	var v_collider := collider._pre_slide_total_velocity

	var v_rel_n := (v_self - v_collider).dot(n)
	print("IMPULSE: self=", name, " collider=", collider.name, " v_rel_n=", v_rel_n, " n=", n)
	if v_rel_n >= 0.0:
		return

	var m_self : float = max(mass, 0.001)
	var m_collider : float = max(collider.mass, 0.001)
	var e : float = clamp(elasticity, 0.0, 1.0)

	# Impulse magnitude (scalar) along normal
	var j := -(1.0 + e) * v_rel_n / (1.0 / m_self + 1.0 / m_collider)

	# Convert impulse to delta-v and apply to each body
	var dv_self := (j / m_self) * n * impulse_scale
	var dv_collider := -(j / m_collider) * n * impulse_scale

	apply_external_impulse(dv_self)
	collider.apply_external_impulse(dv_collider)
