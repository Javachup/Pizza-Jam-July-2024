class_name Health
extends Node

@export var max_health := 3
@onready var health = max_health

signal on_death
signal on_damage

func take_damage(damage_amount := 1):
	
	health -= damage_amount

	print(get_parent().name + " took " + str(damage_amount) + ", and now has " + str(health) + " health")
	
	if health <= 0:
		on_death.emit()
	else:
		on_damage.emit()
