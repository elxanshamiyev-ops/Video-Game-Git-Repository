class_name Player
extends CharacterBody3D

@onready var camera_3d: = $Camera3D
@onready var origCamPos : Vector3 = camera_3d.position
@onready var floorCast := $FloorDetectRayCast
@onready var player_footstep_sound: AudioStreamPlayer3D = $PlayerFootstepSound
@onready var interactRaycast := $Camera3D/InteractRayCast3D
@onready var interact_label: Label = $InteractLabel
@onready var crosshair: Polygon2D = $Crosshair
@onready var fade_in_animation_player: AnimationPlayer = $FadeIn/FadeInAnimationPlayer


var Keys : Array = []

var mouse_sens = 0.15

#Movement#
const SPEED = 4.0
const JUMP_VELOCITY = 7
var isRunning := false
var direction = 1.0
var camBobSpeed :=8.0
var camBobIntensity :=1.0
var _delta = 1
var distanceFootsteps := 0.0
var playFootsteps := 42


func _ready() -> void:
	interact_label.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	fade_in_animation_player.play("Fade_In")

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		camera_3d.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
		camera_3d.rotation.x = clamp(camera_3d.rotation.x,deg_to_rad(-89), deg_to_rad(89))
	if Input.is_action_pressed("run"):
		isRunning = true
	else:
		isRunning = false
	if Input.is_action_just_pressed("interact"):
		print("interact pressed")
		var interacted = interactRaycast.get_collider()
		if interacted != null and interacted.is_in_group("Doors") and interacted.is_in_group("Interactable") and interacted.has_method("action_use"):
			print(interacted.insertedKeys)
			interacted.insertedKeys.append_array(Keys)
			print(interacted.insertedKeys)
		if interacted != null and interacted.is_in_group("Keys")and interacted.is_in_group("Interactable") and interacted.has_method("action_use"):
			print(interacted.keyName)
			Keys.append(interacted.keyName)
		if interacted != null and interacted.is_in_group("Interactable") and interacted.has_method("action_use"):
			interacted.action_use()

	if Input.is_action_just_pressed("Inventory"):
		print(Keys)

func _physics_process(delta: float) -> void:
		# Add the gravity.
	if not is_on_floor():
		if isRunning:
			velocity += get_gravity() * delta*3
		else:
			velocity += get_gravity() * delta*2
	movement(delta)
	jump()
	if floorCast.is_colliding():
		var walkingTerrain = floorCast.get_collider()
		if walkingTerrain != null and walkingTerrain.get_groups().size() > 0:
			var terraingroup = walkingTerrain.get_groups()[0]
			processGroundSounds(terraingroup)
		if interactRaycast.is_colliding():
			if is_instance_valid(interactRaycast.get_collider()):
				if interactRaycast.get_collider().is_in_group("Interactable"):
					interact_label.text = interactRaycast.get_collider().type
					interact_label.visible = true
					crosshair.visible = false
				else:
					interact_label.visible = false
					crosshair.visible = true
		else:
			interact_label.visible = false
			crosshair.visible = true
	pass

func processGroundSounds(group : String):
	if isRunning:
		playFootsteps = 21
	else:
		playFootsteps = 42
	
	if (int(velocity.x) or int(velocity.z) != 0):
		distanceFootsteps += 1
	if distanceFootsteps > playFootsteps and is_on_floor():
		match group:
			"MetalTerrain":
				player_footstep_sound.stream = load("res://Sounds/metal/2.ogg")
			"WoodTerrain":
				player_footstep_sound.stream = load("res://Sounds/wood/3.ogg")
		player_footstep_sound.pitch_scale = randf_range(0.8, 1.2)
		player_footstep_sound.play()
		distanceFootsteps = 0.0

func jump():
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		if isRunning:
			velocity.y = JUMP_VELOCITY*1.5
		else:
			velocity.y = JUMP_VELOCITY

func movement(delta):
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	var actualSpeed := SPEED*2 if isRunning else SPEED
	
	if direction:
		velocity.x = direction.x * actualSpeed
		velocity.z = direction.z * actualSpeed
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	_delta += delta
	var camBobActualSpeed = camBobSpeed*1.5 if isRunning else camBobSpeed
	var camBobActualIntensity = camBobIntensity*2 if isRunning else camBobIntensity
	var cam_bob = floor(abs(direction.z) + abs(direction.x)) * _delta * camBobActualSpeed
	var objCam = origCamPos + Vector3.UP * sin(cam_bob) * camBobActualIntensity
	camera_3d.position = camera_3d.position.lerp(objCam,delta)
	
	move_and_slide()
