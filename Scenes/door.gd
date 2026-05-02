extends Interactable
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var is_Open := false
var can_Interact := true
@export var is_Locked := false
@export var actualKey:String
var insertedKeys:Array=[]


func action_use():
	print(is_Locked)
	print(insertedKeys.has(actualKey))
	if insertedKeys.has(actualKey):
	
		is_Locked = false
	if !is_Locked:
		if  can_Interact:
			if is_Open:
				close()
			else:
				open()
	else:
		locked_open()
	
	
func close():
	animation_player.play("Door_Closed")
	is_Open = false
	can_Interact = false
	pass

func open():
	animation_player.play("Door_Open")
	is_Open = true
	can_Interact = false
	pass

func locked_open():
	animation_player.play("Door_Locked")
	pass

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	can_Interact = true
	pass # Replace with function body.
