class_name Nova extends Player

@onready var slash_box: Area3D = $Hitboxes/Slash
@onready var sweep_box: Area3D = $Hitboxes/Sweep
@onready var poke_box: Area3D = $Hitboxes/Poke
@onready var dash_box: Area3D = $Hitboxes/Dash

@export_category("Damage Values")
@export var attack_dmg: Array[int] = [2, 2, 3, 7, 5]
@export var charged_attack_dmg: int = 10
@export var special_dmg: int = 25
@export_category("Cooldowns")
@export var attack_end_cd: float = 0.25
@export var special_end_cd: float = 0.5
@export var max_combo_time: float = 1
@export_category("Special")
@export var max_charges: int = 3
@export var release_pause: float = 0.5

var combo: int = 0
var combo_timer: float = -1
var action_cd_timer: float = -1

# 1-World, 2-Hitboxes, 3-PlayerHurt, 4-EnemyHurt

func _physics_process(delta):
	super(delta)
	# Cooldown Processing
	action_cd_timer = _tick_timer(delta, action_cd_timer)
	combo_timer = _tick_timer(delta, combo_timer)
	
func _damage_enemy(hits: Array[Node3D], dmg: float) -> void:
	for node in hits:
		if not node is Enemy:
			continue
		(node as Enemy).try_damage(dmg)
	
	
## These are called when a valid input is recieved. It is up to the specific impl to handle attack sequences.
func _basic_attack() -> void:
	if action_cd_timer != -1:
		return
	current_state = PlayerState.ATTACKING
	if combo_timer == -1:
		combo = 0
	var box := slash_box if combo in [0,1] else poke_box if combo in [2,3] else sweep_box # Select hitbox based on combo
	box.monitoring = true
	await get_tree().create_timer(0.3).timeout # Wait for animation
	_damage_enemy(box.get_overlapping_bodies(), attack_dmg[combo])
	box.monitoring = false
	await get_tree().create_timer(0.2).timeout # Wait for animation finish
	action_cd_timer = attack_end_cd
	combo = (combo + 1) % len(attack_dmg)
	combo_timer = max_combo_time
	current_state = PlayerState.IDLE

func _charged_attack() -> void:
	if action_cd_timer != -1:
		return
	current_state = PlayerState.ATTACKING
	sweep_box.monitoring = true
	await get_tree().create_timer(0.3).timeout # Wait for animation
	for i in range(3):
		_damage_enemy(sweep_box.get_overlapping_bodies(), charged_attack_dmg)
		await get_tree().create_timer(0.2).timeout # Animation Tick
	sweep_box.monitoring = false
	await get_tree().create_timer(0.2).timeout # Wait for animation finish
	action_cd_timer = attack_end_cd
	current_state = PlayerState.IDLE
	
func _special_attack() -> void:
	if action_cd_timer != -1:
		return
	current_state = PlayerState.ATTACKING
	dash_box.monitoring = true
	dash()
	await get_tree().physics_frame # Wait a frame for hitbox update
	# Damage
	for node in dash_box.get_overlapping_bodies():
		if not node is Enemy:
			continue
		(node as Enemy).try_damage(special_dmg)
		# (node as Enemy).apply_effect() Burn Effect Maybe?
	sweep_box.monitoring = false
	action_cd_timer = special_end_cd
	special_cd_timer = special_cd
	current_state = PlayerState.IDLE

func _charged_special_attack() -> void:
	if action_cd_timer != -1:
		return
	current_state = PlayerState.ATTACKING
	velocity = Vector3.ZERO
	dash_box.monitoring = true
	for i in range(mini(int(charge_counter/special_charge_time), max_charges)):
		# Updates direction based on input
		var direction = Vector3.ZERO
		if Input.is_action_pressed("move_left"):
			direction.z += 1
		if Input.is_action_pressed("move_right"):
			direction.z -= 1
		if Input.is_action_pressed("move_up"):
			direction.x -= 1
		if Input.is_action_pressed("move_down"):
			direction.x += 1
		direction = direction.rotated(Vector3.UP, deg_to_rad(-45))
		direction = Vector3.FORWARD.rotated(Vector3.UP, rotation.y) if direction == Vector3.ZERO else direction
		look_at(global_position + direction)
		dash()
		await get_tree().physics_frame # Wait a frame for hitbox update
		
		# Damage
		for node in dash_box.get_overlapping_bodies():
			if not node is Enemy:
				continue
			(node as Enemy).try_damage(special_dmg)
			# (node as Enemy).apply_effect() Burn Effect Maybe?
		sweep_box.monitoring = false
		if i < mini(int(charge_counter/special_charge_time), max_charges)-1:
			await get_tree().create_timer(release_pause).timeout # pause between dashes
	velocity = Vector3.FORWARD.rotated(Vector3.UP, rotation.y) * _movement_speed
	action_cd_timer = special_end_cd
	special_cd_timer = special_cd
	current_state = PlayerState.IDLE


## For these make sure to call super first to set player state	
func synergy_burst() -> void:
	super()
	print("BURST!!!!!")
	
func swap_out() -> void:
	super()
	print("Bye!")
	
func swap_in() -> void:
	super()
	print("Hi!")
