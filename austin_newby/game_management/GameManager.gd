extends Node

const LEVEL_PATH := "res://scenes/%s.tscn"
var player_manager : Node3D:
	set(a):
		player_manager = a
		print_rich("[color=dark_gray] - PlayerManager set.")
var player_pos : Vector3:
	get: return player_manager.position
var current_level
var main_scene : MainScene

func _init() -> void:
	print_rich("[color=dark_gray]GameManager initalized.")


func load_level(level_name: String):
	unload_level()
	var path := LEVEL_PATH % level_name
	var new_level := load(path)
	if new_level:
		current_level = new_level.instantiate()
		main_scene.add_child(current_level)
		print_rich("[color=dark_gray]Loaded new level: %s" % [level_name])


func unload_level():
	if (is_instance_valid(current_level)):
		print_rich("[color=dark_gray]Unloaded level: %s" % [current_level.name])
		current_level.queue_free()
		main_scene.get_child(0).queue_free()
	current_level = null
