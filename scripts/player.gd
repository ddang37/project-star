extends CharacterBody3D
class_name Player

var speed = 14
var target_velocity = Vector3.ZERO
#@export_range(0.0, 1.0, 0.01) var camera_follow_speed : float = 0.15

func _physics_process(delta):
	var direction = Vector3.ZERO
	if Input.is_action_pressed("move_left"):
		direction.x += 1
	if Input.is_action_pressed("move_right"):
		direction.x -= 1
	if Input.is_action_pressed("move_up"):
		direction.z += 1
	if Input.is_action_pressed("move_down"):
		direction.z -= 1
	
	if direction != Vector3.ZERO:
		direction = direction.normalized()
		
	if Input.is_action_just_pressed("dodge"):
		direction *= 7
	
	target_velocity.x = direction.x * speed
	target_velocity.z = direction.z * speed
	
	velocity = target_velocity
	move_and_slide()
	
	if Input.is_action_just_pressed("basic_attack"):
		$CameraTarget/PitchPivot.shake(1.0)
	
	#$CameraTarget.position = lerp($CameraTarget.position, position, camera_follow_speed)
