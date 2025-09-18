@abstract
class_name Player extends Entity

enum PlayerState {
	IDLE,
	ATTACKING,
	CHARGING,
	CHARGING_SPECIAL,
	BURSTING
}

@export_category("Input Thresholds")
@export var max_attack_time: float = 0.1
@export var min_charge_time: float = 0.5
@export var special_max_attack_time: float = 0.1
@export var special_min_charge_time: float = 0.75
@export_category("Movement Parameters")
@export var input_smoothing_time: float = 0.1
@export var dash_distance: float = 5

var target_velocity = Vector3.ZERO
var velocity_smoothing_counter: float = 0
var pos: Vector3
var current_state: PlayerState = PlayerState.IDLE
var charge_counter: float = 0

func _ready() -> void:
	get_tree().call_group("Enemies", "PlayerPositionUpd", global_transform.origin)
	current_state = PlayerState.IDLE

func _physics_process(delta):
	# TODO Track player location via GameManager instead
	get_tree().call_group("Enemies", "PlayerPositionUpd", global_transform.origin)
	var direction = Vector3.ZERO
	if Input.is_action_pressed("move_left"):
		direction.z += 1
	if Input.is_action_pressed("move_right"):
		direction.z -= 1
	if Input.is_action_pressed("move_up"):
		direction.x -= 1
	if Input.is_action_pressed("move_down"):
		direction.x += 1
	
	if direction != Vector3.ZERO:
		direction = direction.normalized()
	direction = direction.rotated(Vector3.UP, deg_to_rad(-45))
		
	
	var new_target_velocity = Vector3.ZERO
	new_target_velocity.x = direction.x * _movement_speed
	new_target_velocity.z = direction.z * _movement_speed
	
	if new_target_velocity != target_velocity:
		velocity_smoothing_counter = 0
	if velocity_smoothing_counter < 1:
		velocity_smoothing_counter += delta / input_smoothing_time
	target_velocity = new_target_velocity
	velocity = velocity.lerp(target_velocity, velocity_smoothing_counter)
	move_and_slide()
	if Input.is_action_just_pressed("dodge"):
		position += direction * dash_distance
	
	if Input.is_action_just_pressed("basic_attack"):
		attack_pressed()
	if Input.is_action_just_pressed("special_attack"):
		special_pressed()
	if current_state == PlayerState.CHARGING:
		attack_pressed()
		charge_counter += delta
	elif current_state == PlayerState.CHARGING_SPECIAL:
		special_pressed()
		charge_counter += delta
	
## Used for player manager to handle check if Player is in valid state to swap
func can_swap() -> bool:
	return current_state == PlayerState.IDLE or current_state == PlayerState.CHARGING or current_state == PlayerState.CHARGING_SPECIAL;
	
## Handles Attack Input Logic
func attack_pressed() -> void:
	if current_state == PlayerState.IDLE:
		current_state = PlayerState.CHARGING
		charge_counter = 0
		return
	if current_state == PlayerState.CHARGING and Input.is_action_just_released("basic_attack"):
		current_state = PlayerState.ATTACKING
		if charge_counter < max_attack_time:
			basic_attack()
		elif charge_counter > min_charge_time:
			charged_attack()
		else:
			current_state = PlayerState.IDLE
	
@abstract
func basic_attack() -> void

@abstract
func charged_attack() -> void

## Handles Special Input Logic
func special_pressed() -> void:
	if current_state == PlayerState.IDLE:
		current_state = PlayerState.CHARGING_SPECIAL
		charge_counter = 0
		return
	if current_state == PlayerState.CHARGING_SPECIAL and Input.is_action_just_released("special_attack"):
		current_state = PlayerState.ATTACKING
		if charge_counter < special_max_attack_time:
			special_attack()
		elif charge_counter > special_min_charge_time:
			charged_special_attack()
		else:
			current_state = PlayerState.IDLE
	
@abstract
func special_attack() -> void

@abstract
func charged_special_attack() -> void

@abstract
func synergy_burst() -> void

@abstract
func swap_out() -> void

@abstract
func swap_in() -> void
