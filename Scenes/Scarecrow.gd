extends RigidBody2D


@export var bottom: RigidBody2D

@export var jumpForceRange : Vector2
@export var rotateSpeed: float
@export var maxChargeTime : float

var onFloor : bool = false
var charging : bool = false

var chargeTime : float = 0


func _process(delta: float) -> void:
	if Input.is_action_pressed("left"):
		apply_force(Vector2.LEFT * rotateSpeed)
		
	if Input.is_action_pressed("right"):
		apply_force(Vector2.RIGHT * rotateSpeed)
		
	if Input.is_action_pressed("jump") and onFloor:
		charging = true
		chargeTime += delta
		
	if(Input.is_action_just_released("jump") and charging):
		#apply_force(Vector2.UP.rotated(global_rotation) * 100000)
		var dir = (global_position - bottom.global_position).normalized()
		var jumpForce = lerpf(jumpForceRange.x, jumpForceRange.y, clampf(chargeTime / maxChargeTime, 0, 1))
		apply_force(dir * jumpForce)
		charging = false
		onFloor = false
		chargeTime = 0
		pass
		
	pass


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	pass


func on_bottom_collision(body: Node):
	if body.is_in_group("terrain"):
		onFloor = true
		#stick_bottom()
		pass
	pass
