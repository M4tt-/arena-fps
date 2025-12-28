extends Node

@export_category("Scenes")
@export var level_scene: PackedScene
@export var environment_scene: PackedScene
@export var player_scene: PackedScene
@export var enemy_scene: PackedScene

@onready var world := $World
@onready var actors := $Actors

func _ready() -> void:
	_spawn_world()
	_spawn_player()
	_spawn_enemy(Vector3(1,1,1), 0)

func _spawn_world() -> void:
	if environment_scene:
		var env := environment_scene.instantiate()
		world.add_child(env)

	if level_scene:
		var level := level_scene.instantiate()
		world.add_child(level)

func _spawn_player() -> void:
	if not player_scene:
		return

	var player := player_scene.instantiate()
	actors.add_child(player)

	# Optional: put player somewhere sensible for testing
	if player is Node3D:
		player.global_position = Vector3(0, 1, 10)

func _spawn_enemy(pos: Vector3, behavior: int) -> void:
	if not enemy_scene:
		return

	var e := enemy_scene.instantiate() as Enemy
	e.global_position = pos
	e.behavior = behavior
	actors.add_child(e)
