extends Node3D

class_name Wave

@export var mobs: Array[PackedScene]

# Elimination-based wave progression, could also implement time-based
@export_category("Wave Type")
@export var isEleminationBased = true
@export var enemiesLeft = 0
