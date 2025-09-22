class_name Nova extends Player

@onready var sweep_box: Area3D = $Hitboxes/Sweep
@onready var hit_box: Area3D = $Hitboxes/Hit
@onready var dash_box: Area3D = $Hitboxes/Dash

@export_category("Damage Values")
@export var attack_damage: Array[int] = [2, 2, 3, 7, 5]

var combo: int = 0
var cd_attack: float = -1
var cd_special: float = -1

# 1-World, 2-Hitboxes, 3-PlayerHurt, 4-EnemyHurt

func _physics_process(delta):
	super(delta)
	# Cooldown Processing
	if cd_attack != -1 and cd_attack > 0:
		cd_attack -= delta
		if cd_attack <= 0:
			cd_attack = -1
	if cd_special != -1 and cd_special > 0:
		cd_special -= delta
		if cd_special <= 0:
			cd_special = -1
	
## These are called when a valid input is recieved. It is up to the specific impl to handle attack sequences.
func _basic_attack() -> void:
	if cd_attack != -1:
		return
	for node in sweep_box.get_overlapping_bodies():
		if not node is Enemy:
			continue
		(node as Enemy).try_damage(3)
	current_state = PlayerState.IDLE
	
func _register_hit() -> void:
	return

func _charged_attack() -> void:
	print("Charged for "+str(charge_counter))
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
