extends CharacterBody3D
class_name Projectile

@export var data: ProjectileData
@export var impart_scale: float = 1.0 # unitless
@export var _time_alive: float = 0.0 # seconds

@onready var _collision: CollisionShape3D = $CollisionShape3D
@onready var _mesh: MeshInstance3D = $MeshInstance3D  # optional

@export var damage: float = 25.0

func _find_health(collider: Node) -> Health:
	# Check the body and walk up parents (colliders are often children)
	# The key is the collider has a child Node named "Health".
	# Health should have a script that implements "apply_damage()"
	var p: Node = collider
	while p:
		var h := p.find_child("Health", true, false) as Health
		if h:
			return h
		p = p.get_parent()
	return null

func initialize(origin: Vector3, direction: Vector3, shooter_velocity: Vector3) -> void:
	if data == null:
		push_error("Projectile has no ProjectileData.")
		return

	global_position = origin

	# Size (collision)
	var sphere := _collision.shape as SphereShape3D
	if sphere:
		sphere.radius = data.radius

	# Optional: size the visible mesh to match collision
	if _mesh and _mesh.mesh is SphereMesh:
		# SphereMesh radius is separate from node scale; easiest is scale node
		_mesh.scale = Vector3.ONE * (data.radius / 0.5)  # assuming default sphere radius ~0.5 in your mesh

	# Velocity with inheritance
	var forward := direction.normalized()
	velocity = forward * data.speed + shooter_velocity * data.inherit_factor

func _physics_process(delta: float) -> void:
	if data == null:
		queue_free()
		return

	_time_alive += delta
	if _time_alive >= data.life_time:
		queue_free()
		return

	# Gravity / drop
	if data.gravity != 0.0:
		velocity.y -= data.gravity * delta

	# Swept move (good for fast and slow projectiles)
	var collision := move_and_collide(velocity * delta)
	if collision:
		# Later: damage/explosion/impact effects
		var collider := collision.get_collider()
		print("HIT: ", collider, " at ", collision.get_position(), " normal ", collision.get_normal())
		
		# Deal Damage
		var health := _find_health(collider)
		if health:
			health.apply_damage(damage)

		# Impart Momentum
		if collider and collider.has_method("apply_external_impulse"):

			# Projectile momentum p = m * v
			var p : Vector3 = data.mass * velocity

			# Transfer momentum to target as a delta-v: Δv = p / m_target
			var dv_target : Vector3 = (p / max(collider.mass, 0.001)) * impart_scale
			collider.apply_external_impulse(dv_target)

		queue_free()
