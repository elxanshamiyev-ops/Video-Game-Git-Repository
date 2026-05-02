extends Area3D
@export var PathToNextLevel: String = ""


func _on_body_entered(body: Node3D) -> void:
	if body is Player and PathToNextLevel != "":
		print("Next level")
		get_tree().change_scene_to_file(PathToNextLevel)
		pass
