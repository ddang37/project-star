@abstract
class_name Player extends Entity

enum PlayerState {
	SLEEPING,
	IDLE,
	ATTACKING,
	CHARGING,
	BURSTING
}

var target_velocity = Vector3.ZERO
var pos: Vector3
var current_state: PlayerState = PlayerState.SLEEPING
var charge_counter: float = 0

func _ready() -> void:
	get_tree().call_group("Enemies", "PlayerPositionUpd", global_transform.origin)

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
		
	if Input.is_action_just_pressed("dodge"):
		direction *= 30
	
	target_velocity.x = direction.x * _movement_speed
	target_velocity.z = direction.z * _movement_speed
	
	velocity = target_velocity
	move_and_slide()
	
	if current_state == PlayerState.CHARGING:
		charge_counter += delta
	
func can_swap() -> bool:
	return current_state == PlayerState.IDLE or current_state == PlayerState.CHARGING;
	
func basic_attack() -> bool:
	if current_state != PlayerState.IDLE: 
		return false;
	current_state = PlayerState.ATTACKING
	return true;

func charged_attack() -> bool:
	if current_state != PlayerState.IDLE: 
		return false;
	current_state = PlayerState.ATTACKING
	return true;
	
func special_attack() -> bool:
	if current_state != PlayerState.IDLE: 
		return false;
	current_state = PlayerState.ATTACKING
	return true;

func charged_special_attack() -> bool:
	if current_state != PlayerState.IDLE: 
		return false;
	current_state = PlayerState.ATTACKING
	return true;

func synergy_burst() -> bool:
	if current_state != PlayerState.IDLE: 
		return false;
	current_state = PlayerState.ATTACKING
	return true;

@abstract
func break_swap_out() -> void

@abstract
func break_swap_in() -> void
