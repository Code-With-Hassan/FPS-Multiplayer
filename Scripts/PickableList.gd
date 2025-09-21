extends Control

@onready var scrollContainer = $ScrollContainer
@onready var pickableContainer = $ScrollContainer/VBoxContainer

const PICKABLE = preload("res://Prefabs/pickable.tscn")

func _ready() -> void:
	scrollContainer.visible = false

func _physics_process(delta: float) -> void:
	self.visible = pickableContainer.get_child_count() > 0
	if pickableContainer.get_child_count() > 0:
		print("show")

func add_pickable(texture: Texture2D, head: String, description: String):
	var newPickable = PICKABLE.instantiate()
	newPickable.setHead(head)
	newPickable.setDescription(description)
	newPickable.setTexture(texture)
	pickableContainer.add_child(newPickable)
	
func remove_pickable(texture: String):
	for i in pickableContainer.get_children():
		if i.texture_rect.texture.resource_path == texture:
			pickableContainer.remove_child(i)
			break

func _on_texture_button_toggled(toggled_on: bool) -> void:
	scrollContainer.visible = toggled_on
