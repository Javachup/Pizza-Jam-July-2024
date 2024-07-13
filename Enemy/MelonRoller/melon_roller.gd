extends Area2D

@onready var health = %Health
@onready var right_area = %RightArea
@onready var left_area = %LeftArea
@onready var roll_animation_player = %RollAnimationPlayer

@export var speed := 100
var direction := Vector2.LEFT :
	set(value):
		direction = value.normalized()
		roll_animation_player.speed_scale = sign(value.dot(Vector2.RIGHT))

var colliding_bodies = []

func _physics_process(delta):
	position += speed * delta * direction

	if !left_area.has_overlapping_bodies():
		direction = Vector2.RIGHT
	if !right_area.has_overlapping_bodies():
		direction = Vector2.LEFT

func _on_health_on_death():
	queue_free()
