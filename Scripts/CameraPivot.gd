extends Node3D

var player
@onready var camera3d = $Camera3D
var currentCamera

func _ready() -> void:
	currentCamera = camera3d
	player = get_parent()

func _on_camera_drag_gui_input(event: InputEvent) -> void:
	if event is InputEventScreenDrag:
		self.rotation.x = clamp(self.rotation.x - (event.relative.y) / 1000 * Manager.CAMERA_SENSIVITY, -.43, .83)

func _input(event: InputEvent) -> void:
	if OS.get_name() == "Windows":
		if event is InputEventMouseMotion:
			self.rotation.x = clamp(self.rotation.x - (event.relative.y) / 1000 * Manager.CAMERA_SENSIVITY, -.90, .83)

func get_target_position():
	var pos: Vector3
	var start  = currentCamera.project_ray_origin(player.crossHair.global_position)
	var end = currentCamera.project_position(player.crossHair.global_position, 1000)
	
	pos = end
	var param = PhysicsRayQueryParameters3D.new()
	param.from = start
	param.to = end
	
	var result = get_world_3d().direct_space_state.intersect_ray(param)
	
	if result.size() > 0:
		pos = result.position
	return pos
