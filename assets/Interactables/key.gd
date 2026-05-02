extends Interactable

@export var keyName:String

func action_use():
	print("I am a key")
	
	queue_free()
	
	pass
