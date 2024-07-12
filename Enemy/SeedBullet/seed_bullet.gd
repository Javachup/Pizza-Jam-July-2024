class_name SeedBullet
extends AnimatableBody2D

@export var speed := 100
var direction := Vector2.ZERO :
	set(value):
		direction = value.normalized()

func _physics_process(delta):
	position += speed * delta * direction
