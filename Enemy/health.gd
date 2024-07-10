class_name Health
extends Node

@export var max_health := 3
@onready var health = max_health

signal on_death

func take_damage(damage_amount := 1):
	health -= damage_amount

	if health <= 0:
		on_death.emit()
