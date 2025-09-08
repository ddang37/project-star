## Abstract class 
class_name EntityEffect

var _entity: Entity

## Called whenever the [EntityEffect] is applied or reapplied.[br]
## Returns false if provided [Entity] is null, true if valid
func try_apply(entity: Entity) -> bool:
	if not entity:
		assert(false, "Entity not provided for effect")
		return false
	_entity = entity
	return true

## Called to process the [EntityEffect] and indicate when it is done.[br]
## Returns true if still in progress, returns false if effect has finished.
func process(delta: float) -> bool:
	return false

## Called when the [EntityEffect] should be removed.[br]
## Performs any necessary cleanup and applies any permanent effects.[br]
func stop() -> void:
	pass
