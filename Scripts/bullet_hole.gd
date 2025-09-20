extends Node3D

var bulletHoleDestroyTime: float = 0

func _physics_process(delta: float) -> void:
	bulletHoleDestroyTime += delta
	if bulletHoleDestroyTime >= Manager.BULLET_HOLE_DESTROY_DELAY_TIME:
		queue_free()
