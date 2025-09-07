extends Node3D

var current_char: CharacterBody3D

func _ready() -> void:
	# TODO: Should load or somehow maintain the character's selected char throughout scenes
	# e.g. if the player leaves scene1 and enters scene 2, they should have the same selected character
	current_char = get_child(0) # temp
	current_char.set_process_mode(Node.PROCESS_MODE_ALWAYS)
	for char in get_children():
		if char.name != current_char.name:
			char.visible = false
			char.set_process_mode(Node.PROCESS_MODE_DISABLED)
	

func _process(delta: float) -> void:
	if (Input.is_action_just_pressed("select_char1")):
		change_char(0)
	elif (Input.is_action_just_pressed("select_char2")):
		change_char(1)
	elif (Input.is_action_just_pressed("select_char3")):
		change_char(2)

func change_char(idx: int):
	if idx < get_child_count() and current_char.name != get_child(idx).name:
			current_char.visible = false
			current_char.set_process_mode(Node.PROCESS_MODE_DISABLED)
			get_child(idx).set_global_transform(current_char.get_global_transform())
			
			current_char = get_child(idx)
			current_char.visible = true
			current_char.set_process_mode(Node.PROCESS_MODE_ALWAYS)
