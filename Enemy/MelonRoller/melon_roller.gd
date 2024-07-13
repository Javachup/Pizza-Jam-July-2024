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

func swap_direction():
	if direction == Vector2.LEFT:
		direction = Vector2.RIGHT
	else:
		direction = Vector2.LEFT

func _physics_process(delta):
	position += speed * delta * direction

	if !left_area.has_overlapping_bodies():
		direction = Vector2.RIGHT
	if !right_area.has_overlapping_bodies():
		direction = Vector2.LEFT

func _on_health_on_death():
	queue_free()

func _on_enter_area_body_entered(body):
	swap_direction()

func _on_enter_area_area_entered(area):
	swap_direction()
