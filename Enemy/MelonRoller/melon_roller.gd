extends Area2D

@onready var health = %Health
@onready var right_area = %RightArea
@onready var left_area = %LeftArea

@export var speed := 100
var direction := Vector2.LEFT :
	set(value):
		direction = value.normalized()

var colliding_bodies = []

func _physics_process(delta):
	position += speed * delta * direction

	if !left_area.has_overlapping_bodies():
		direction = Vector2.RIGHT
	if !right_area.has_overlapping_bodies():
		direction = Vector2.LEFT

func _on_health_on_death():
	queue_free()
