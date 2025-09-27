extends PlayerState

var time_active: float = 0

func enter(_previous_state_path: String, _data := {}) -> void:
	time_active = 0;
	

func update(_delta: float) -> void:
	pass

func physics_update(delta: float) -> void:
	player.move(delta, 0.25)

	time_active += delta

	if Input.is_action_just_pressed("synergy_burst"):
		finished.emit(BURSTING)
	if Input.is_action_just_pressed("dodge"):
		player.dash()
		finished.emit(MOVING if player.velocity else IDLE)
	elif  Input.is_action_just_released("basic_attack"):
		if time_active > player.attack_charge_time:
			finished.emit(ATTACKING_CHARGED, {"charge_time": time_active})
		else:
			finished.emit(ATTACKING)
		
func end() -> void:
	pass
	

func exit() -> void:
	pass
