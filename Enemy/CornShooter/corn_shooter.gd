extends Node2D

@export var seed_bullet:PackedScene

var is_hiding := false

func shoot():
	var dir = Vector2.RIGHT
	var bullet = seed_bullet.instantiate() as SeedBullet
	bullet.position = position
	bullet.direction = dir
	get_tree().root.add_child(bullet)

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

func _unhandled_input(event):
	if event.is_action_pressed("ui_accept"):
		shoot()
