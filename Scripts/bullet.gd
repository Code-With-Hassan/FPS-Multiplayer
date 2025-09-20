extends RigidBody3D

@export var _power := 10
@export var speed := 400
var direction: Vector3 = Vector3.ZERO

const BULLET_HOLE = preload("res://Prefabs/BulletHole.tscn")

func _physics_process(delta: float) -> void:
	if direction:
		var collision =  move_and_collide(direction * delta * speed)
		if collision is KinematicCollision3D:
			add_bullet_hole(collision.get_position(), collision.get_normal())
			queue_free()

func add_bullet_hole(collisionPostion, normal) -> void:
	var bulletHole = BULLET_HOLE.instantiate()
	bulletHole.global_position = collisionPostion
	bulletHole.look_at_from_position(collisionPostion, normal*100)
	get_tree().get_first_node_in_group("temp_objects").add_child(bulletHole)
