extends RigidBody2D


@export var bottom: RigidBody2D
@export var sprite: Sprite2D
@export var chargeCurve: Curve
@export var returnToStandingCurve : Curve

@export var jumpForceRange : Vector2
@export var rotateSpeed: float
@export var maxChargeTime : float
@export var returnToStandingTime : float
@export var chargeSpriteDistanceMult : float

var onFloor : bool = false
var charging : bool = false

var distToBottom : float = 0

var chargeTime : float = 0

var standingReturnTimePassed : float = 1000

var spriteLoggedDist : float = 0


func _enter_tree() -> void:
	distToBottom = (bottom.global_position - global_position).length()


func _process(delta: float) -> void:
	sprite.global_rotation = bottom.global_rotation
	
	if Input.is_action_pressed("left"):
		apply_force(Vector2.LEFT * rotateSpeed)
		
	if Input.is_action_pressed("right"):
		apply_force(Vector2.RIGHT * rotateSpeed)
		
	if Input.is_action_pressed("jump") and onFloor:
		charging = true
		chargeTime += delta
		
		#var vecToBottom = bottom.global_position - global_position
		var dirToBottom = (bottom.global_position - global_position).normalized()
		sprite.global_position = global_position.lerp(global_position + dirToBottom * distToBottom * chargeSpriteDistanceMult, chargeCurve.sample(clampf(chargeTime / maxChargeTime, 0, 1)))
		
		
	if(Input.is_action_just_released("jump") and charging):
		#apply_force(Vector2.UP.rotated(global_rotation) * 100000)
		var dir = (global_position - bottom.global_position).normalized()
		var jumpForce = lerpf(jumpForceRange.x, jumpForceRange.y, clampf(chargeTime / maxChargeTime, 0, 1))
		apply_force(dir * jumpForce)
		charging = false
		onFloor = false
		chargeTime = 0
		standingReturnTimePassed = 0
		spriteLoggedDist = (sprite.global_position - global_position).length()
		
	if onFloor == false and charging == false:
		var spriteInitialPos : Vector2 = global_position + (bottom.global_position - global_position).normalized() * spriteLoggedDist
		sprite.global_position = lerp(spriteInitialPos, global_position, returnToStandingCurve.sample(clamp(standingReturnTimePassed / returnToStandingTime, 0, 1)))
		standingReturnTimePassed += delta
	pass


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	pass


func on_bottom_collision(body: Node):
	if body.is_in_group("terrain"):
		onFloor = true
		#stick_bottom()
		pass
	pass
