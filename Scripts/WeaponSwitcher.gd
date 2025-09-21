@tool
extends Panel

@export_range(0.0, 1.0) var _transparency: float = 1.0

enum STATE {SELECTED, UNSELECTED}
var state = STATE.SELECTED
var gun = null


func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			if get_child(0).text != "":
				select()
				get_parent().slot_selected.emit(gun)
				
func _process(delta: float) -> void:
	self.modulate.a = _transparency
	
func select() -> void:
	var style: StyleBoxFlat = get("theme_override_styles/panel")
	style.border_width_top = 1
	style.border_width_bottom = 1
	style.border_width_left = 1
	style.border_width_right = 1
	state = STATE.SELECTED
	get_parent().unselect(self)
	
func unselect():
	var style: StyleBoxFlat = get("theme_override_styles/panel")
	style.border_width_top = 0
	style.border_width_bottom = 0
	style.border_width_left = 0
	style.border_width_right = 0
	state = STATE.UNSELECTED
