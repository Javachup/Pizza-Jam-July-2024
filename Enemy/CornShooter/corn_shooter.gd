extends Node2D

var is_hiding := false

func hide_corn():
	is_hiding = true
	scale.y = 0.1

func reveal_corn():
	is_hiding = false
	scale.y = 1.0

func _on_hide_area_body_entered(body):
	hide_corn()

func _on_hide_area_body_exited(body):
	reveal_corn()
