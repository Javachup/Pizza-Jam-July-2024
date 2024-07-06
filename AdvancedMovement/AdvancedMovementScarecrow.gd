extends RigidBody2D


@export var bottom: RigidBody2D
@export var sprite: Sprite2D
@export var chargeCurve: Curve
@export var returnToStandingCurve : Curve

@export var jumpForceRange : Vector2
@export var rotateSpeed: float
@export var maxChargeAngle : float
@export var returnToStandingTime : float
@export var chargeSpriteDistanceMult : float
@export var resetRotationSpeed: float
@export var correctionSpeed : float
@export var landingDamp : float

var onFloor : bool = false
var charging : bool = false

var distToBottom : float = 0

var chargeTime : float = 0

var standingReturnTimePassed : float = 1000

var spriteLoggedDist : float = 0

var leftCharging = false
var rightCharging = false


func _enter_tree() -> void:
	distToBottom = (bottom.global_position - global_position).length()


func _physics_process(delta: float) -> void:
	sprite.global_rotation = bottom.global_rotation
	
	if Input.is_action_just_pressed("right") and onFloor:
		apply_force(Vector2.RIGHT.rotated(global_rotation) * rotateSpeed)
		rightCharging = true
		charging = true
		
	if Input.is_action_just_pressed("left") and onFloor:
		apply_force(Vector2.LEFT.rotated(global_rotation) * rotateSpeed)
		leftCharging = true
		charging = true
		
	if charging:
		#if (sprite.global_rotation_degrees < 0 and leftCharging) or (sprite.global_rotation_degrees > 0 and rightCharging):
			#chargeTime += delta
			#if chargeTime >= maxChargeTime:
				#linear_velocity = Vector2.ZERO
		
		if leftCharging and sprite.global_rotation_degrees <= -maxChargeAngle:
			linear_velocity = Vector2.ZERO
			#apply_force(Vector2.RIGHT.rotated(global_rotation) * correctionSpeed)
			
		elif rightCharging and sprite.global_rotation_degrees >= maxChargeAngle:
			linear_velocity = Vector2.ZERO
			#pass
		
	if (Input.is_action_just_released("right") or Input.is_action_just_released("left")) and charging:
		linear_velocity = Vector2.ZERO
		charging = false
		jump()
		
	if sprite.global_rotation_degrees < 0 and (rightCharging or !charging): # Counter Clockwise
		apply_force(Vector2.RIGHT.rotated(global_rotation) * resetRotationSpeed)
	elif sprite.global_rotation_degrees > 0 and (leftCharging or !charging):
		apply_force(Vector2.LEFT.rotated(global_rotation) * resetRotationSpeed)
			
			
		
		
	
	
	#var appliedForce = false
	
	#if Input.is_action_pressed("left"):
		#apply_force(Vector2.LEFT.rotated(global_rotation) * rotateSpeed)
		#appliedForce = true 
		#
	#if Input.is_action_pressed("right"):
		#apply_force(Vector2.RIGHT.rotated(global_rotation) * rotateSpeed)
		#appliedForce = !appliedForce # If we had applied left, cancels out
		#
	#if !appliedForce and !charging:
		#if sprite.global_rotation_degrees < 0: # Counter Clockwise
			#apply_force(Vector2.RIGHT.rotated(global_rotation) * resetRotationSpeed)
		#elif sprite.global_rotation_degrees > 0:
			#apply_force(Vector2.LEFT.rotated(global_rotation) * resetRotationSpeed)
			#
			#
		#
	#if Input.is_action_pressed("jump") and onFloor:
		#charging = true
		#chargeTime += delta
		#
		##var vecToBottom = bottom.global_position - global_position
		#var dirToBottom = (bottom.global_position - global_position).normalized()
		#sprite.global_position = global_position.lerp(global_position + dirToBottom * distToBottom * chargeSpriteDistanceMult, chargeCurve.sample(clampf(chargeTime / maxChargeTime, 0, 1)))
		#
		#
	if(Input.is_action_just_released("jump") and charging):
		jump()
		
	#if onFloor == false and charging == false:
		#var spriteInitialPos : Vector2 = global_position + (bottom.global_position - global_position).normalized() * spriteLoggedDist
		#sprite.global_position = lerp(spriteInitialPos, global_position, returnToStandingCurve.sample(clamp(standingReturnTimePassed / returnToStandingTime, 0, 1)))
		#standingReturnTimePassed += delta
	#pass


func jump():
	var dir = (global_position - bottom.global_position).normalized()
	var jumpForce = lerpf(jumpForceRange.x, jumpForceRange.y, clampf(abs(sprite.global_rotation_degrees) / maxChargeAngle, 0, 1))
	apply_force(dir * jumpForce)
	charging = false
	onFloor = false
	leftCharging = false
	rightCharging = false
	chargeTime = 0
	standingReturnTimePassed = 0
	spriteLoggedDist = (sprite.global_position - global_position).length()


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	pass


func on_bottom_collision(body: Node):
	if body.is_in_group("terrain"):
		onFloor = true
		linear_velocity *= landingDamp
		#stick_bottom()
		pass
	pass
