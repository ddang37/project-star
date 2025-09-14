class_name RangedEnemy extends Enemy

@export var speed = 1
@export var target_node: Node3D

var target_desired_distance = attack_radius
func _ready():
	navigation_agent.target_desired_distance = target_desired_distance

func recalc_path():
	if (target_node):
		set_movement_target(target_node.global_position)
	
func _on_recalculate_timer_timeout() -> void:
	recalc_path()

func attack() -> void: 
	
	print("is attacking")
	is_attacking = false

func _on_aggro_area_body_entered(body: Node3D) -> void:
	if (body.name.substr(0, 7) == "Player"):
		target_node = body
