extends CharacterBody3D

@export var speed = 50

@export var path_desired_distance = 4
@export var target_desired_distance = 4

@export var nav_agent: NavigationAgent3D
 
@onready var target_node: Node3D = $"../Player"


var home_position = Vector3.ZERO

func _ready():
	home_position = self.global_position
	nav_agent.path_desired_distance = path_desired_distance
	nav_agent.target_desired_distance = target_desired_distance

func _physics_process(_delta):
	if (nav_agent.is_navigation_finished()):
		return
	
	var axis = to_local(nav_agent.get_next_path_position()).normalized()
	velocity = axis * speed
	
	nav_agent.set_velocity(velocity)
	move_and_slide()
	
func recalc_path():
	if (target_node):
		nav_agent.set_target_position (target_node.global_position)
	else:
		nav_agent.set_target_position(home_position)


func _on_recalculate_timer_timeout() -> void:
	recalc_path()
