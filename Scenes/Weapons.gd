extends HBoxContainer

signal slot_selected(gun)

@onready var leftWeapon = $LeftWeapon
@onready var rightWeapon = $RightWeapon
@onready var leftWeaponLabel = $LeftWeapon/Label
@onready var rightWeaponLabel = $RightWeapon/Label

func add_gun(gun_name: String, gun) -> void:
	if !has_two_gun():
		if leftWeaponLabel.text != "":
			rightWeaponLabel.text = gun_name
			rightWeapon.gun = gun
			rightWeapon.select()
			return
		else:
			leftWeaponLabel.text = gun_name
			leftWeapon.gun = gun
			leftWeapon.select()
			return
			
		if rightWeaponLabel.text != "":
			leftWeaponLabel.text = gun_name
			leftWeapon.gun = gun
			leftWeapon.select()
			return
		else:
			rightWeaponLabel.text = gun_name
			rightWeapon.gun = gun
			rightWeapon.select()
			return
	else:
		get_current_selected_weapon().text = gun_name
		get_current_selected_weapon().get_parent().gun = gun

func remove_gun():
	get_current_selected_weapon().text = ""
	get_current_selected_weapon().get_parent().gun = null
	get_current_selected_weapon().get_parent().unselect()
		
func has_two_gun():
	return leftWeaponLabel.text != "" and rightWeaponLabel.text != ""
	
func get_current_selected_weapon():
	return leftWeaponLabel if leftWeapon.state == leftWeapon.STATE.SELECTED else rightWeaponLabel

func get_secondary_weapon():
	return leftWeaponLabel if get_current_selected_weapon() == rightWeaponLabel else rightWeaponLabel

func unselect(ref):
	if ref == leftWeapon:
		rightWeapon.unselect()
	else:
		leftWeapon.unselect()
