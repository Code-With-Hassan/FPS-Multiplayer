extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 3.5

@export var joyStick : Node2D
@export var cameraDrag: Control
@export var jumpButton: Panel
@export var crossHair: Node
@export var fireButton: Panel
@export var adsButton: Panel

@onready var cameraPivot = $CameraPivot
@onready var camera3d = $CameraPivot/Camera3D
@onready var gunPivot = $CameraPivot/GunPivot
@onready var playerWalkingAnimation = $PlayerWalkingAnimation
@onready var AdsPivot = $CameraPivot/AdsPivot
@onready var AdsCamera = $CameraPivot/AdsCamera3D
@onready var foot = $Foot
@onready var pickableList = $UI/PickableList

var CAMERA_INIT_POSITION : Vector3
var ads_enabled: bool 

func _ready() -> void:
	set_plateform_configuration()
	CAMERA_INIT_POSITION = camera3d.position
	if has_gun():
		get_current_gun().isDropped = false

func _physics_process(delta: float) -> void:
	handle_inputs(delta)
	
func handle_inputs(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if OS.get_name() == "Windows":
		# Handle jump.
		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = JUMP_VELOCITY
	
		if  Input.is_action_just_released("ads") or Input.is_action_just_pressed("ads"):
			toggle_ads()
		
		if Input.is_action_just_pressed("drop_gun"):
			drop_gun()
		
	if ads_enabled:
		AdsCamera.current = true
		cameraPivot.currentCamera = AdsCamera
		AdsCamera.global_position = lerp(AdsCamera.global_position ,AdsPivot.global_position, .2)
	else:
		AdsCamera.global_position = lerp(AdsCamera.global_position, camera3d.global_position, .2)
		if AdsCamera.global_position.is_equal_approx(camera3d.global_position):
			camera3d.current = true
			cameraPivot.currentCamera = camera3d
	
	var input_dir
	if OS.get_name() == "Android":
		if joyStick.has_method("get_direction"):
			input_dir = joyStick.get_direction()
	else:
		if Input.is_action_just_pressed("fire") and has_gun():
			get_current_gun().fire_bullet()
		
		input_dir = Input.get_vector("left", "right", "up", "down")
		
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		playerWalkingAnimation.play("player_walking_animation")
		if !crossHair.spread_played:
			crossHair.play_spread()
			crossHair.spread_played = true
		
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		
	else:
		playerWalkingAnimation.stop(true)
		camera3d.position = lerp(camera3d.position, CAMERA_INIT_POSITION, .15)
		if crossHair.spread_played:
			crossHair.play_spread_backward()
			crossHair.spread_played = false
		
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	
func _on_camera_drag_gui_input(event: InputEvent) -> void:
	if event is InputEventScreenDrag:
		self.rotation.y -= event.relative.x / 1000 * Manager.CAMERA_SENSIVITY

func set_plateform_configuration():
	if OS.get_name() == "Android":
		joyStick.show()
		cameraDrag.show()
		jumpButton.show()
		fireButton.show()
		adsButton.show()
	else:
		joyStick.hide()
		cameraDrag.hide()
		jumpButton.hide()
		fireButton.hide()
		adsButton.hide()
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
	if OS.get_name() == "Windows":
		if event is InputEventMouseMotion:
			self.rotation.y -= event.relative.x / 1000 * Manager.CAMERA_SENSIVITY

func _on_jump_button_pressed() -> void:
	if is_on_floor():
		velocity.y = JUMP_VELOCITY

func _on_fire_button_pressed() -> void:
	if has_gun():
		get_current_gun().fire_bullet()

func toggle_ads() -> void:
	if has_gun():
		ads_enabled = !ads_enabled
		if ads_enabled:
			crossHair.hide()
		else:
			crossHair.show()

func _on_ads_button_pressed() -> void:
	toggle_ads()
	
func drop_gun():
	if has_gun():
		var currentGun = get_current_gun()
		var gun: Node3D = currentGun.duplicate()
		var temp_objects = get_tree().get_first_node_in_group("temp_objects")
		gun.global_position = foot.global_position
		gun.rotation_degrees.x = 90
		currentGun.queue_free()
		temp_objects.add_child(gun)
	if ads_enabled:
		ads_enabled = false
		
func has_gun() -> bool:
	return gunPivot.get_child_count() > 0
		
func get_current_gun() -> Node3D:
	return gunPivot.get_child(0);

func show_pickable(texture: Texture2D, head: String, description: String) -> void:
	pickableList.add_pickable(texture, head, description)
	
func hide_pickable(texture: String) -> void:
	pickableList.remove_pickable(texture)
	
	
	
