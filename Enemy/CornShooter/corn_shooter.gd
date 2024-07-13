extends Node2D

@export var seed_bullet:PackedScene
@export var health : Health

@onready var animation_player = %AnimationPlayer
@onready var shoot_timer = %ShootTimer
@onready var shoot_location = %ShootLocation
@onready var sprite_2d = %Sprite2D
@onready var hide_area = %HideArea

var is_hiding := false # When the enemy should/shouldn't take damage
var target = null

func shoot():
	if target == null:
		return
	if is_hiding:
		return

	var dir = (target.position - position).normalized()
	var bullet = seed_bullet.instantiate() as SeedBullet
	bullet.position = shoot_location.global_position
	bullet.direction = dir
	get_tree().root.add_child(bullet)

func set_is_hiding(value:bool):
	is_hiding = value

func hide_corn():
	shoot_timer.paused = true
	animation_player.play("Hide")
	# is_hiding set in the animation itself

func reveal_corn():
	shoot_timer.paused = false
	animation_player.play("Show")
	# is_hiding set in the animation itself
	# Idle animation played in the animation itself

func _get_should_hide() -> bool:
	return hide_area.has_overlapping_bodies() or hide_area.has_overlapping_areas()

func _process(_delta):
	if target == null:
		return

	sprite_2d.flip_h = target.global_position.x > global_position.x

func _physics_process(_delta):
	if _get_should_hide() != is_hiding:
		if is_hiding:
			reveal_corn()
		else:
			hide_corn()

func _on_see_area_body_entered(body):
	target = body

func _on_see_area_body_exited(_body):
	target = null

func _on_shoot_timer_timeout():
	shoot()

func _on_health_on_death():
	queue_free()
