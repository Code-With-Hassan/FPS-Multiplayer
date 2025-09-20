extends Node3D

@onready var muzzle_flash = $MuzzleFlash
@onready var animationPlayer = $AnimationPlayer
@onready var shotMarker = $ShotMarker

var Bullet = preload("res://Prefabs/bullet.tscn")
const FIRE_DELAY = .4
var fireTime: float

var cameraPivot 
var tempObjects

func _physics_process(delta: float) -> void:
	fireTime += delta

func _ready() -> void:
	if get_tree().has_group("camera_pivot"):
		cameraPivot = get_tree().get_nodes_in_group("camera_pivot")[0]
	if get_tree().has_group("temp_objects"):
		tempObjects = get_tree().get_nodes_in_group("temp_objects")[0]

func fire_bullet():
	if fireTime >= FIRE_DELAY:
		muzzle_flash.emitting = true
		animationPlayer.play("fire_animation")
		var bullet = Bullet.instantiate()
		tempObjects.add_child(bullet)
		bullet.global_position = shotMarker.global_position
		bullet.look_at(cameraPivot.get_target_position())
		bullet.direction = bullet.global_position.direction_to(cameraPivot.get_target_position())
		fireTime = 0
