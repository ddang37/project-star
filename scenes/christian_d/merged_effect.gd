class_name Merged extends EntityEffect

var merger: MindMerger
var index: int
var active: bool
var target: Vector3

func _init(_id: EntityEffect.EffectID, _merger: MindMerger, _index: int) -> void:
	merger = _merger
	index = _index
	active = true
	merger.update.connect(func (pos) -> void: target = pos[_index])
	merger.reindex.connect(func () -> void: active = false)
	
func process(_delta: float) -> bool:
	(_entity as Enemy).set_movement_target(target)
	# Something Else
	return active;

func stop() -> void:
	return;
