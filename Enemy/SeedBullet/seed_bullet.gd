class_name SeedBullet
extends AnimatableBody2D

@export var speed := 100
@export var damage := 3

@onready var sprite_2d = %Sprite2D
const SPIN_RATE = -12

var direction := Vector2.ZERO :
	set(value):
		direction = value.normalized()

func _physics_process(delta):
	position += speed * delta * direction
	sprite_2d.rotate(delta * SPIN_RATE)
