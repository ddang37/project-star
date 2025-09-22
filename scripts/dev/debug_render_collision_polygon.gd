extends CollisionShape3D

func _ready() -> void:
	var m = MeshInstance3D.new()
	m.mesh = shape.get_debug_mesh()
	add_child(m)
