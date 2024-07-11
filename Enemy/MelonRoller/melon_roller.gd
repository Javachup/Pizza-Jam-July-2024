extends AnimatableBody2D

@onready var health = %Health
@onready var collision_shape_2d = $RightArea/CollisionShape2D

@export var speed := 300
var direction := Vector2.LEFT :
	set(value):
		direction = value.normalized()

func set_direction(to_right:bool):
	if to_right:
		direction = Vector2.RIGHT
	else:
		direction = Vector2.LEFT

func _physics_process(delta):
	position += speed * delta * direction

func _on_health_on_death():
	queue_free()
