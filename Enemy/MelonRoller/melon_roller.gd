extends CharacterBody2D

@onready var health = %Health

@export var speed := 100

func _ready():
	velocity.x = -speed

func _physics_process(_delta):
	move_and_slide()

func _on_health_on_death():
	queue_free()



func _on_temp_timeout():
	health.take_damage()
