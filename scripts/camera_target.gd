extends Node3D
class_name  CameraTarget

@onready var player = get_parent()
@export_range(0.0, 1.0, 0.01) var follow_speed: float = 0.15

func _physics_process(delta: float) -> void:
	position = lerp(position, player.position, follow_speed)
