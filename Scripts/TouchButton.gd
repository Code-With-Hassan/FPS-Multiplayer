@tool
extends Panel

signal pressed

@onready var label = $Label
@export var button_text: String
@export_range(0.0, 1.0) var _transparancy : float = 1.0

func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.is_pressed():
			pressed.emit()
	pass
	
func _physics_process(delta: float) -> void:
	label.text = button_text
	self.modulate.a = _transparancy
