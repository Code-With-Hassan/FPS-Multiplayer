extends Node

signal object_picked(obj_id)

var CAMERA_SENSIVITY : int = 5
var BULLET_HOLE_DESTROY_DELAY_TIME : float = 3
var CURSOR_MODE_ENABLED: bool = false

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("cursor_mode_toggler"):
		if !CURSOR_MODE_ENABLED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		CURSOR_MODE_ENABLED = !CURSOR_MODE_ENABLED
