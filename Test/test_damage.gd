extends Node


@export var player : Scarecrow


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("up"):
		player.health.take_damage(1)
		pass
