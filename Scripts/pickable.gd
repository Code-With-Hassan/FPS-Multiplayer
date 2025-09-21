extends Control

@onready var head: Label = $HBoxContainer/ColorRect/VBoxContainer/Title
@onready var Description: Label = $HBoxContainer/ColorRect/VBoxContainer/Description
@onready var textureRect: TextureRect = $HBoxContainer/MarginContainer/TextureRect

func setHead(text: String) -> void:
	head.text = text
	
func setDescription(text: String) -> void:
	Description.text = text
	
func setTexture(texture: Texture2D) -> void:
	textureRect.texture = texture

func _on_input_gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			Manager.object_picked.emit(textureRect.texture.resource_path)
			queue_free()
