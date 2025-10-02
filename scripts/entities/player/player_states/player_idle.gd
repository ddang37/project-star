extends PlayerState


func enter(_previous_state_path: String, _data := {}) -> void:
	entered.emit()
	player.velocity = Vector3.ZERO

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	player.move_and_slide()

	if Input.is_action_just_pressed("synergy_burst"):
		trigger_finished.emit(BURSTING)
	elif Input.is_action_just_pressed("special_attack") and player.has_special:
		trigger_finished.emit(CHARGING_SPECIAL)
	elif Input.is_action_just_pressed("basic_attack"):
		trigger_finished.emit(CHARGING)
	elif Input.get_vector("move_down", "move_up", "move_left", "move_right") != Vector2.ZERO:
		trigger_finished.emit(MOVING)	
		
func end() -> void:
	pass
		
func exit() -> void:
	pass
