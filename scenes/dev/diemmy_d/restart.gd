extends Area3D

var player: CharacterBody3D

func _ready() -> void:
	var player_manager = get_node("/root/Prototype/PlayerManager")
	player = player_manager.current_char


func _on_body_entered(body: CharacterBody3D) -> void:
	if (player == body) : #in case switching player
		# print("that's the player")
		#reload the current scene, need changes if want to go to menu scene
		get_tree().reload_current_scene() 
	
	
