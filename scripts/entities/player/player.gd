@abstract
class_name Player extends Entity

enum PlayerState {
	IDLE,
	ATTACKING,
	SPECIALING,
	CHARGING,
	CHARGING_SPECIAL,
	BURSTING,
	SWITCHING
}

@onready var ray: RayCast3D = $ForwardRay

@export_category("Input Thresholds")
@export var max_click_time: float = 0.25
@export var attack_charge_time: float = 0.5
@export var special_charge_time: float = 0.75
@export_category("Movement Parameters")
@export var input_smoothing_time: float = 0.1
@export var dash_distance: float = 5
@export_category("Cooldowns")
@export var special_cd: float = 5
@export var dash_cd: float = 1

var _delta: float = 0
var target_velocity = Vector3.ZERO
var velocity_smoothing_counter: float = 0
var pos: Vector3
var current_state: PlayerState = PlayerState.IDLE
var charge_counter: float = 0
var special_cd_timer: float = -1
var dash_cd_timer: float = -1

func _ready() -> void:
	get_tree().call_group("Enemies", "PlayerPositionUpd", global_transform.origin)
	current_state = PlayerState.IDLE
	
func _tick_timer(delta: float, timer: float):
	if timer != -1 and timer > 0:
		timer -= delta
		if timer <= 0:
			timer = -1
	return timer

func _physics_process(delta):
	_delta = delta
	special_cd_timer = _tick_timer(delta, special_cd_timer)
	dash_cd_timer = _tick_timer(delta, dash_cd_timer)
	# TODO Track player location via GameManager instead
	get_tree().call_group("Enemies", "PlayerPositionUpd", global_transform.origin)
	# Lose movement control mid attack animation or during burst
	if current_state != PlayerState.ATTACKING and current_state != PlayerState.BURSTING:
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
		if current_state == PlayerState.CHARGING or current_state == PlayerState.CHARGING_SPECIAL:
			direction *= 0.25	
		direction = direction.rotated(Vector3.UP, deg_to_rad(-45))
			
		
		var new_target_velocity = Vector3.ZERO
		new_target_velocity = direction * _movement_speed
		
		if new_target_velocity != target_velocity:
			velocity_smoothing_counter = 0
		if velocity_smoothing_counter < 1:
			velocity_smoothing_counter += delta / input_smoothing_time
		target_velocity = new_target_velocity
		
		# Dash supercedes charge attacks but not regular attacks (no animation cancelling)
		if Input.is_action_just_pressed("dodge") and dash_cd_timer == -1:
			if current_state == PlayerState.IDLE:
				dash()
				dash_cd_timer = dash_cd
			if (current_state == PlayerState.CHARGING or current_state == PlayerState.CHARGING_SPECIAL) and charge_counter > max_click_time:
				dash()
				dash_cd_timer = dash_cd
				current_state = PlayerState.IDLE
		velocity = velocity.lerp(target_velocity, velocity_smoothing_counter)
		look_at(global_position + velocity)
	
	# Attack processing
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
		
	move_and_slide()
	
## Used for player manager to handle check if Player is in valid state to swap
func can_swap() -> bool:
	return current_state == PlayerState.IDLE or current_state == PlayerState.CHARGING or current_state == PlayerState.CHARGING_SPECIAL;

## Dash function, uses raycast to prevent clipping world but ignores entities
func dash() -> void:
	ray.force_raycast_update()
	position = ray.get_collision_point() if ray.is_colliding() \
			else position + Vector3.FORWARD.rotated(Vector3.UP, rotation.y) * dash_distance

## Handles Attack Input Logic
func attack_pressed() -> void:
	if current_state == PlayerState.IDLE:
		current_state = PlayerState.CHARGING
		charge_counter = 0
		return
	if current_state == PlayerState.CHARGING and Input.is_action_just_released("basic_attack"):
		current_state = PlayerState.IDLE
		if charge_counter < max_click_time:
			_basic_attack()
		elif charge_counter > attack_charge_time:
			_charged_attack()

## Triggers when valid Attack Input
@abstract func _basic_attack() -> void

## Triggers when valid Charged Attack Input
@abstract func _charged_attack() -> void

## Handles Special Input Logic
func special_pressed() -> void:
	if current_state == PlayerState.IDLE and special_cd_timer == -1:
		current_state = PlayerState.CHARGING_SPECIAL
		charge_counter = 0
		return
	if current_state == PlayerState.CHARGING_SPECIAL and Input.is_action_just_released("special_attack"):
		current_state = PlayerState.IDLE
		if charge_counter < max_click_time:
			_special_attack()
		elif charge_counter > special_charge_time:
			_charged_special_attack()
	
## Triggers when valid Special Attack Input
@abstract func _special_attack() -> void

## Triggers when valid Charged Special Attack Input
@abstract func _charged_special_attack() -> void

## Calls Synergy Burst Animation TODO: Maybe make synergy bursts centrallized in manager
func synergy_burst() -> void:
	current_state = PlayerState.BURSTING

## Calls Swap Out Animation
func swap_out() -> void:
	current_state = PlayerState.SWITCHING

## Calls Swap In Animation
func swap_in() -> void:
	current_state = PlayerState.SWITCHING
