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
