class_name Nova extends Player

func _physics_process(delta):
	super(delta)
	
func basic_attack() -> void:
	print("Attack")
	await get_tree().create_timer(0.4).timeout
	current_state = PlayerState.IDLE

func charged_attack() -> void:
	print("Charged for "+str(charge_counter))
	current_state = PlayerState.IDLE
	
func special_attack() -> void:
	print("Special!!!")
	current_state = PlayerState.IDLE

func charged_special_attack() -> void:
	print("Special!!! Charged for "+str(charge_counter))
	current_state = PlayerState.IDLE
	
func synergy_burst() -> void:
	print("BURST!!!!!")
	
func swap_out() -> void:
	print("Bye!")
	
func swap_in() -> void:
	print("Hi!")
