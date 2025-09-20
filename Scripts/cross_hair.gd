extends Node2D

@onready var animation_player = $AnimationPlayer

var spread_played = false

func play_spread():
	animation_player.play("spread")
	
func play_spread_backward():
	animation_player.play_backwards("spread")
