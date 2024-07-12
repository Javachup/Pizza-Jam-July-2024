extends Node2D

@export var seed_bullet:PackedScene

var is_hiding := false
var target = null

func shoot():
	if target == null:
		return

	var dir = (target.position - position).normalized
	var bullet = seed_bullet.instantiate() as SeedBullet
	bullet.position = position
	bullet.direction = dir
	get_tree().root.add_child(bullet)

func hide_corn():
	is_hiding = true
	$AnimatedSprite2D.scale.y = 0.1

func reveal_corn():
	is_hiding = false
	$AnimatedSprite2D.scale.y = 1.0

func _on_hide_area_area_entered(area):
	hide_corn()

func _on_hide_area_body_entered(body):
	hide_corn()

func _on_hide_area_area_exited(area):
	reveal_corn()

func _on_hide_area_body_exited(body):
	reveal_corn()

func _on_see_area_body_entered(body):
	target = body

func _on_see_area_body_exited(body):
	target = null

func _on_shoot_timer_timeout():
	shoot()
