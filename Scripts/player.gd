extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 3.5

@export var joyStick : Node2D
@export var cameraDrag: Control
@export var jumpButton: Panel
@export var crossHair: Node
@export var fireButton: Panel
@export var adsButton: Panel

@onready var weaponsContainer = $UI/Weapons
@onready var secondaryGunPivot = $CameraPivot/SecondaryGunPivot
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

var near_objects = {}

func _ready() -> void:
	set_plateform_configuration()
	CAMERA_INIT_POSITION = camera3d.position
	Manager.object_picked.connect(func (obj_id):
		pick_object(obj_id)
	)
	weaponsContainer.slot_selected.connect(func (gun):
		select_gun(gun)
	)
	if has_gun():
		get_current_gun().isDropped = false
		weaponsContainer.add_gun(get_current_gun().Head, get_current_gun())

func _physics_process(delta: float) -> void:
	handle_inputs(delta)
	
func handle_inputs(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if OS.get_name() == "Windows" and !Manager.CURSOR_MODE_ENABLED:
		# Handle jump.
		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = JUMP_VELOCITY
	
		if  Input.is_action_just_released("ads") or Input.is_action_just_pressed("ads"):
			toggle_ads()
		
		if Input.is_action_just_pressed("drop_gun"):
			drop_gun()
		
		if Input.is_action_just_pressed("fire") and has_gun():
			get_current_gun().fire_bullet()
		
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
	if event is InputEventScreenDrag and !Manager.CURSOR_MODE_ENABLED:
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
	if OS.get_name() == "Windows" and !Manager.CURSOR_MODE_ENABLED:
		if event is InputEventMouseMotion:
			self.rotation.y -= event.relative.x / 1000 * Manager.CAMERA_SENSIVITY

func _on_jump_button_pressed() -> void:
	if is_on_floor() and !Manager.CURSOR_MODE_ENABLED:
		velocity.y = JUMP_VELOCITY

func _on_fire_button_pressed() -> void:
	if has_gun() and !Manager.CURSOR_MODE_ENABLED:
		get_current_gun().fire_bullet()

func toggle_ads() -> void:
	if has_gun() and !Manager.CURSOR_MODE_ENABLED:
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
		weaponsContainer.remove_gun()
		temp_objects.add_child(gun)
	if ads_enabled:
		ads_enabled = false
		
func has_gun() -> bool:
	return gunPivot.get_child_count() > 0
		
func get_current_gun() -> Node3D:
	return gunPivot.get_child(0);

func show_pickable(texture: Texture2D, head: String, description: String, object) -> void:
	near_objects[texture.resource_path] = object 
	pickableList.add_pickable(texture, head, description)
	
func hide_pickable(texture: String) -> void:
	near_objects.erase(texture)
	pickableList.remove_pickable(texture)
	
func get_object_by_id(obj_id) -> Node3D:
	return near_objects[obj_id]
	
func pick_object(obj_id: String) -> void:
	var obj: Node3D = get_object_by_id(obj_id)
	var new: Node3D = obj.duplicate()
	if weaponsContainer.has_two_gun():
		drop_gun()
	else:
		if has_gun():
			add_secondary_gun(obj_id)
			return
	
	gunPivot.add_child(new)
	obj.queue_free()
	new.isDropped = false
	new.rotation_degrees.x = 0
	new.rotation_degrees.y = -90
	var t = get_tree().create_tween()
	t.tween_property(new, "position", Vector3.ZERO, .2).set_ease(Tween.EASE_OUT)
	t.play()
	weaponsContainer.add_gun(new.head, new)

func add_secondary_gun(obj_id):
	var obj: Node3D = get_object_by_id(obj_id)
	var new: Node3D = obj.duplicate()
	secondaryGunPivot.add_child(new)
	new.position = Vector3.ZERO
	obj.queue_free()
	new.isDropped = false
	new.rotation_degrees.x = 0
	new.rotation_degrees.y = 0
	new.rotation_degrees.z = 70
	weaponsContainer.add_gun(new.head, new)
	 
func select_gun(gun):
	var dup: Node3D = gun.duplicate()
	if !has_gun():
		gunPivot.add_child(dup)
		gun.queue_free()
		dup.isDropped = false
		dup.position = Vector3.ZERO
		dup.rotation_degrees = Vector3.ZERO
	else:
		if gun != get_current_gun():
			var pri = get_current_gun()
			var sec = get_secondary_gun()
			
			var pri_dup : Node3D = pri.duplicate()
			var sec_dup : Node3D = sec.duplicate()
			pri_dup.isDropped = false
			sec_dup.isDropped = false
			weaponsContainer.get_current_selected_weapon().get_parent().gun = sec_dup
			weaponsContainer.get_secondary_weapon().get_parent().gun = pri_dup
			pri.queue_free()
			sec.queue_free()
			
			secondaryGunPivot.add_child(pri_dup)
			gunPivot.add_child(sec_dup)
			var temp_rot = pri_dup.rotation_degrees
			var temp_pos = pri_dup.position
			pri_dup.position = sec_dup.position
			pri_dup.rotation_degrees = sec_dup.rotation_degrees
			sec_dup.position = temp_pos
			sec_dup.rotation_degrees = temp_rot

func get_secondary_gun() -> Node3D:
	return secondaryGunPivot.get_child(0)
