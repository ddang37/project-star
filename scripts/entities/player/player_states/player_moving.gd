extends PlayerState
	

func enter(_prev_state: String, _data := {}):
	entered.emit()

func update(_delta: float) -> void:
	pass

func physics_update(delta: float) -> void:
	player.move(delta)
	if Input.is_action_just_pressed("dodge"):
		player.dash()

	if Input.is_action_just_pressed("synergy_burst"):
		trigger_finished.emit(BURSTING)
	elif Input.is_action_just_pressed("special_attack") and player.has_special:
		trigger_finished.emit(CHARGING_SPECIAL)
	elif Input.is_action_just_pressed("basic_attack"):
		trigger_finished.emit(CHARGING)
	elif not Input.get_vector("move_down", "move_up", "move_left", "move_right"):
		trigger_finished.emit(IDLE)
			
func end() -> void:
	pass
		
func exit() -> void:
	pass
