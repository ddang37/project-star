class_name Set

var _data: Dictionary

func _init(existing_data=null) -> void:
	_data = {}
	if not existing_data:
		return
	elif existing_data is Dictionary:
		for key in existing_data:
			_data.set(key, true)
	elif existing_data is Array:
		# If array contains duplicate elements, we disregard
		for i in existing_data:
			_data.set(i, true)
	else:
		assert(false, "Set was initialized with invalid data")

func add(item) -> bool:
	return _data.set(item, true)

func remove(item) -> bool:
	return _data.erase(item)

func contains(item) -> bool:
	return _data.has(item)

func size() -> int:
	return _data.size()

func clear():
	_data.clear()

func iterable() -> Dictionary:
	return _data
