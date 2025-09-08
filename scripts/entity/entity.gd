@abstract
class_name Entity extends CharacterBody3D

enum Faction {PLAYER, NEUTRAL, HOSTILE}

@export var _movement_speed: float = 1.0
@export var faction: Faction = Faction.NEUTRAL
@export var _hp: float = 10.0
@export var _max_hp: float = 10.0

var _status_effects: Set = Set.new()
var _stopped_effects: Set = Set.new()

func _process(delta: float) -> void:
	for effect: EntityEffect in _status_effects.iterable():
		if not effect.process(delta):
			effect.stop()
			_stopped_effects.add(effect)
	for effect: EntityEffect in _stopped_effects.iterable():
		_status_effects.remove(effect)
	_stopped_effects.clear()

func try_damage(damage_amount: float) -> bool:
	if damage_amount <= 0:
		assert(false, "Damage amount cannot be <= 0")
		return false
	var new_hp: float = _hp - damage_amount
	if new_hp > 0.0:
		_hp = new_hp
		return true
	else:
		_hp = 0.0
		trigger_death()
		return true

func try_heal(heal_amount: float) -> bool:
	if heal_amount <= 0:
		assert(false, "Heal amount cannot be <= 0")
		return false
	var new_hp: float = _hp + heal_amount
	if new_hp > _max_hp:
		_hp = _max_hp
		return true
	else:
		_hp = new_hp
		return true

func trigger_death():
	queue_free()
