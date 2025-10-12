class_name MossyPedes extends Enemy


var mossy: CharacterBody3D 
var player: Player

# make sure mossy and area in different levels, area mask same layers as player
# current player layer: 2, 3

# idle
var initial_pos = Vector3(0,0,0)
var radius = 5.0
var base_speed = 0.5
var speed = base_speed
var angle = 0.0
var current_pos = Vector3(0,0,0)
var is_idle = false

var player_detected = false
var flower: MeshInstance3D

func _ready() -> void:
	mossy = self #the script is attached to mossy-pedes
	initial_pos = global_position #rotate around where it was placed initially
	
	var player_manager = get_node("/root/Prototype/PlayerManager")
	player = player_manager.current_char
	
	flower = $flower_mesh
	if (flower.material_override == null): # too lazy to pick a standard color
		flower.material_override = StandardMaterial3D.new()
		flower.material_override.albedo_color = Color.GREEN
	
	is_idle = true
	
func _process(delta: float) -> void: #run every frame
	if (is_idle):
		idle(delta)
	
	if (player_detected): # flower change color based on distance
		var distance = global_position.distance_to(player.global_position)
		if (distance < 5):
			flower.material_override.albedo_color = Color.RED
			is_idle = true
			speed = base_speed * 2
		elif (distance < 10):
			flower.material_override.albedo_color = Color.YELLOW
		else:
			flower.material_override.albedo_color = Color.GREEN
			is_idle = false
			speed = base_speed

		
	

func idle(delta: float) -> void: #move in circle
	# movement
	angle += delta * speed
	var x = radius * cos(angle)
	var z = radius * sin(angle)
	global_position	= Vector3(x, global_position.y, z)
	current_pos = global_position
	
	# direction
	var direction = Vector3(-radius * sin(angle), 0, radius * cos(angle)).normalized()
	look_at(global_position + direction, Vector3.UP)
	
	


func _on_area_3d_body_entered(body: Node3D) -> void:
	if (player == body) : #in case switching player
		global_position = Vector3(current_pos.x, current_pos.y - 1.1, current_pos.z)
		current_pos = global_position
		player_detected = true
		is_idle = false



func _on_area_3d_body_exited(body: Node3D) -> void:
	if (player == body) : #in case switching player
		global_position = Vector3(current_pos.x, current_pos.y + 1.1, current_pos.z)
		current_pos = global_position
		player_detected = false
		is_idle = true
		

func respawn() -> void: # not being used yet
	print("respawn")
	angle = 0.0
	global_position = initial_pos
	is_idle = true

func _physics_process(_delta: float) -> void:
	return
	# this function is not working: Cannot call method 'get_navigation_map' on a null value.
