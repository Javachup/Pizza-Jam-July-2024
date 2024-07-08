extends RigidBody2D


@export var scarecrow : Scarecrow


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	scarecrow.bottom_integrate_forces(state)
