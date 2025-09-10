class_name MindMerger extends RigidBody3D

signal update(pos: Array[Vector3])
signal killed

@export_category("Rotation")
@export var ROTATION_SPEED_DEG_PER_SEC: float = 60
@export var MIN_ROTATION_WAIT:float = 3
@export var MAX_ROTATION_WAIT: float = 8
@export_category("Expansion")
@export var MINION_OFFSET: float = 7
@export var MAX_EXPANSION: float = 2
@export var EXPANSION_SPEED: float = 0.5
@export var EXPANSION_CURVE: Curve
		
	
@export_category("Movement")
@export var SPEED: float = 5
@export var SLOW_DIST: float = 1
@export var FOLLOW_MIN_DIST: float = 5

# Merger Vars
var minions: Array
var minion_pos: Array[Vector3] = []
var rotation_offset: float = 0
var rotation_flip_wait: float = 0
var rotation_flip_mult: int = 1
var expansion_time: float = 0
var expansion_mult: int = 1

# Movement Vars
var player: Player
var target: Vector3

# Run by Enemy Manager on Merger Spawn. vRegisters and Configures Minions
func setup(_minions) -> void:
	minions = _minions as Array
	minion_pos.resize(minions.size())
	for i in range(minions.size()):
		(minions[i] as MergerTestEnemy).merge_with(self, i)
		(minions[i] as MergerTestEnemy).killed.connect(remove_minion)
	
func _process(delta: float) -> void:
	## Calculates Minion Rotation
	if (rotation_flip_wait <= 0):
		rotation_flip_wait = lerp(MIN_ROTATION_WAIT, MAX_ROTATION_WAIT, randf())
		rotation_flip_mult *= -1
	rotation_offset += ROTATION_SPEED_DEG_PER_SEC * delta * rotation_flip_mult
	if (abs(rotation_offset) >= 360): # Float Modulus for Offset Wrapping
		rotation_offset -= sign(rotation_offset)*360
	rotation_flip_wait -= delta # Reduce cooldown Timer	
	
	## Calculates Minion Expansion
	expansion_time += EXPANSION_SPEED * delta * expansion_mult
	if (expansion_time >= 1 or expansion_time <= 0):
		expansion_mult *= -1
		expansion_time += EXPANSION_SPEED * delta * expansion_mult
	
	## Calculates Minion Positions and sends to Minions
	for i in range(minions.size()):
		minion_pos[i] = global_position + (Vector3.RIGHT * (MINION_OFFSET + MAX_EXPANSION * EXPANSION_CURVE.sample(expansion_time))).rotated(Vector3.UP, deg_to_rad(i * 360 / minions.size() + rotation_offset))
	update.emit(minion_pos)
		
	## Sets Movement Target to be FOLLOW_MIN_DIST from Player. If has no Minions, Follow Twice as far.
	target = player.global_position-(player.global_position-global_position).normalized()*FOLLOW_MIN_DIST*(2 if minions.size() == 0 else 1)
	
## Executes Movement to Target
func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	var err = (target-global_position)
	err = err.lerp(Vector3.ZERO, 1-err.length()/SLOW_DIST)*SPEED if err.length() < SLOW_DIST else err.normalized()*SPEED
	state.linear_velocity = Vector3(err.x, -1, err.z)
	state.angular_velocity = Vector3.ZERO	
	
## Unregisteres Minion from Merger, Reduces Shape to one less Vertex
func remove_minion(n: int) -> void:
	if minions.size() == 3:
		for i in range(minions.size()):
			(minions[i] as MergerTestEnemy).unmerge()
		minions.clear()
		minion_pos.clear()
		return
	minions.remove_at(n)
	minion_pos.remove_at(n)
	for i in range(minions.size()):
		(minions[i] as MergerTestEnemy).merge_num_update(i)
		
func kill() -> void:
	killed.emit()
	self.queue_free()
