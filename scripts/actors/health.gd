extends Node
class_name Health

signal changed(current: float, max: float)
signal died

@export var max_health: float = 100.0
@export var current_health: float = 100.0
@export var health_bar_path: NodePath = ^"../UiAnchor/HealthBar" # adjust if your bar is elsewhere

@onready var _bar: Node = get_node_or_null(health_bar_path)

func _ready() -> void:
	current_health = clamp(current_health, 0.0, max_health)
	_update_bar()
	changed.emit(current_health, max_health)

func apply_damage(amount: float) -> void:
	print("DAMAGE: ", owner, " (Health node: ", get_path(), ") amount=", amount)
	if amount <= 0.0:
		return
	current_health = max(0.0, current_health - amount)
	_update_bar()
	changed.emit(current_health, max_health)
	if current_health <= 0.0:
		died.emit()

func heal(amount: float) -> void:
	if amount <= 0.0:
		return
	current_health = min(max_health, current_health + amount)
	_update_bar()
	changed.emit(current_health, max_health)

func _update_bar() -> void:
	print("Update bar: cur=", current_health, "/", max_health, " bar=", _bar)
	if _bar and _bar.has_method("set_percent"):
		var p := current_health / max_health if max_health > 0.0 else 0.0
		_bar.call("set_percent", p)
	else:
		if _bar:
			print("Bar exists but has no set_percent(): ", _bar, " methods? ", _bar.get_method_list())

func reset_full() -> void:
	current_health = max_health
	_update_bar()
	changed.emit(current_health, max_health)
