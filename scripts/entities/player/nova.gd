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
@export var special_cd: float = 5
@export var special_end_cd: float = 5
@export var max_combo_time: float = 0.75
@export_category("Charged Controls")
@export var max_charges: int = 3
@export var charge_time: float = 1.0

var combo: int = 0
var combo_timer: float = -1
var action_cd_timer: float = -1
var special_cd_timer: float = -1
var current_attack: AttackType = AttackType.NONE

# 1-World, 2-Hitboxes, 3-PlayerHurt, 4-EnemyHurt

func _physics_process(delta):
	super(delta)
	# Cooldown Processing
	action_cd_timer = _tick_timer(delta, action_cd_timer)
	special_cd_timer = _tick_timer(delta, special_cd_timer)
	combo_timer = _tick_timer(delta, combo_timer)
	
	
func _tick_timer(delta: float, timer: float):
	if timer != -1 and timer > 0:
		timer -= delta
		if timer <= 0:
			timer = -1
	return timer
	
	
## These are called when a valid input is recieved. It is up to the specific impl to handle attack sequences.
func _basic_attack() -> void:
	if action_cd_timer != -1:
		return
	current_state = PlayerState.ATTACKING
	if combo_timer == -1:
		combo = 0
	var box := slash_box if combo in [0,1,2] else poke_box if combo == 3 else sweep_box # Select hitbox based on combo
	box.monitoring = true
	await get_tree().create_timer(0.5).timeout # Wait for animation
	for node in box.get_overlapping_bodies():
		if not node is Enemy:
			continue
		(node as Enemy).try_damage(attack_dmg[combo])
	box.monitoring = false
	await get_tree().create_timer(0.5).timeout # Wait for animation finish
	action_cd_timer = attack_end_cd
	combo = (combo + 1) % len(attack_dmg)
	combo_timer = max_combo_time
	current_state = PlayerState.IDLE

func _charged_attack() -> void:
	if action_cd_timer != -1 or special_cd_timer != -1:
		return
	current_state = PlayerState.ATTACKING
	sweep_box.monitoring = true
	await get_tree().create_timer(0.5).timeout # Wait for animation
	for i in range(3):
		for node in sweep_box.get_overlapping_bodies():
			if not node is Enemy:
				continue
			(node as Enemy).try_damage(charged_attack_dmg)
		await get_tree().create_timer(0.1).timeout
	sweep_box.monitoring = false
	await get_tree().create_timer(0.2).timeout # Wait for animation finish
	action_cd_timer = special_end_cd
	special_cd_timer = special_cd
	current_state = PlayerState.IDLE
	
func _special_attack() -> void:
	print("Special!!!")
	current_state = PlayerState.IDLE

func _charged_special_attack() -> void:
	print("Special!!! Charged for "+str(charge_counter))
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
