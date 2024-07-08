extends RigidBody2D

class_name Scarecrow


@export var bottom: RigidBody2D
@export var sprite: Sprite2D
@export var chargeCurve: Curve
@export var returnToStandingCurve : Curve
@export var groundRaycast : RayCast2D

@export var jumpForceRange : Vector2
@export var rotateSpeed: float
@export var maxChargeAngle : float
@export var returnToStandingTime : float
@export var chargeSpriteDistanceMult : float
@export var resetRotationSpeed: float
@export var correctionSpeed : float
@export var landingDamp : float
@export var superJumpLinearDamp : float
@export var superJumpPower : float
@export var glideGravityScaleMult : float
@export var glideAcceleration : float
@export var maxGlideSpeed : float
@export var slamGravityMult : float
@export var slamBounce : float
@export var justLaunchedBuffer : float

var onFloor : bool = false
var charging : bool = false

var distToBottom : float = 0

var chargeTime : float = 0

var standingReturnTimePassed : float = 1000

var spriteLoggedDist : float = 0

var leftCharging = false
var rightCharging = false

var chargingSuperJump = false

var startLinearDamp : float

var gliding : bool = false

var ogGravityScale : float

var glidingJustStarted : bool = false

var slamming : bool = false

var justLaunchedBufferTime : float


func _enter_tree() -> void:
	distToBottom = (bottom.global_position - global_position).length()
	startLinearDamp = linear_damp
	ogGravityScale = bottom.gravity_scale


func _physics_process(delta: float) -> void:
	
	justLaunchedBufferTime += delta
	
	print(groundRaycast.is_colliding())
	if groundRaycast.is_colliding() and justLaunchedBufferTime > justLaunchedBuffer:
		onFloor = true
		
	else:
		onFloor = false
	
	
	sprite.global_rotation = bottom.global_rotation
	
	
	
	if Input.is_action_just_pressed("right") and onFloor:
		apply_force(Vector2.RIGHT.rotated(global_rotation) * rotateSpeed)
		rightCharging = true
		charging = true
		linear_velocity = Vector2.ZERO
		
	if Input.is_action_just_pressed("left") and onFloor:
		apply_force(Vector2.LEFT.rotated(global_rotation) * rotateSpeed)
		leftCharging = true
		charging = true
		linear_velocity = Vector2.ZERO
		
	if Input.is_action_just_pressed("jump") and onFloor and !charging:
		chargingSuperJump = true
		
	if Input.is_action_just_released("jump") and chargingSuperJump:
		chargingSuperJump = false
		linear_velocity = Vector2.ZERO
		linear_damp = startLinearDamp
		jump_with_dir(superJumpPower, Vector2.UP)
		
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
		jump(lerpf(jumpForceRange.x, jumpForceRange.y, clampf(abs(sprite.global_rotation_degrees) / maxChargeAngle, 0, 1)))
		
	if sprite.global_rotation_degrees < 0 and (rightCharging or !charging): # Counter Clockwise
		apply_force(Vector2.RIGHT.rotated(global_rotation) * resetRotationSpeed)
	elif sprite.global_rotation_degrees > 0 and (leftCharging or !charging):
		apply_force(Vector2.LEFT.rotated(global_rotation) * resetRotationSpeed)
			
			
	if onFloor and chargingSuperJump:
		bottom.apply_force(Vector2.DOWN * 1000000)
		apply_force(Vector2.UP * 100000)
		linear_damp = superJumpLinearDamp
		#bottom.freeze
		pass	
	
		
	if !onFloor and Input.is_action_pressed("glide") and linear_velocity.y >= 0 and !slamming:
		glidingJustStarted = !gliding
		gliding = true
			
	else:
		gliding = false
		
		
	if gliding:
		bottom.gravity_scale = 0
		gravity_scale = ogGravityScale * glideGravityScaleMult
		#bottom.gravity_scale = ogGravityScale * glideGravityScaleMult
	else:
		bottom.gravity_scale = ogGravityScale
		gravity_scale = 0
		#bottom.gravity_scale = ogGravityScale


	if glidingJustStarted and !onFloor and gliding:
		bottom.linear_velocity.y = 0
		linear_velocity.y = 0
		
	
	if gliding and Input.is_action_pressed("right"):
		apply_force(Vector2.RIGHT * glideAcceleration / 2.0)
		bottom.apply_force(Vector2.RIGHT * glideAcceleration / 2.0)
		linear_velocity.x = clampf(linear_velocity.x, -maxGlideSpeed, maxGlideSpeed)
		bottom.linear_velocity.x = clampf(bottom.linear_velocity.x, -maxGlideSpeed, maxGlideSpeed)
		
	if gliding and Input.is_action_pressed("left"):
		apply_force(Vector2.LEFT * glideAcceleration / 2.0)
		bottom.apply_force(Vector2.LEFT * glideAcceleration / 2.0)
		linear_velocity.x = clampf(linear_velocity.x, -maxGlideSpeed, maxGlideSpeed)
		bottom.linear_velocity.x = clampf(bottom.linear_velocity.x, -maxGlideSpeed, maxGlideSpeed)

	if !onFloor and Input.is_action_just_pressed("slam") and !slamming:
		slamming = true
		bottom.gravity_scale = ogGravityScale * slamGravityMult
		bottom.physics_material_override.bounce = slamBounce
	elif !slamming and !gliding:
		bottom.gravity_scale = ogGravityScale
		
	
	
	
	
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
	#if(Input.is_action_just_released("jump") and charging):
		#jump(lerpf(jumpForceRange.x, jumpForceRange.y, clampf(abs(sprite.global_rotation_degrees) / maxChargeAngle, 0, 1)))
		#
	#if onFloor == false and charging == false:
		#var spriteInitialPos : Vector2 = global_position + (bottom.global_position - global_position).normalized() * spriteLoggedDist
		#sprite.global_position = lerp(spriteInitialPos, global_position, returnToStandingCurve.sample(clamp(standingReturnTimePassed / returnToStandingTime, 0, 1)))
		#standingReturnTimePassed += delta
	#pass


func jump(jumpForce : float):
	var dir = (global_position - bottom.global_position).normalized()
	jump_with_dir(jumpForce, dir)
	
	
func jump_with_dir(jumpForce : float, dir : Vector2):
	apply_force(dir * jumpForce)
	charging = false
	onFloor = false
	leftCharging = false
	rightCharging = false
	chargeTime = 0
	standingReturnTimePassed = 0
	spriteLoggedDist = (sprite.global_position - global_position).length()
	justLaunchedBufferTime = 0


func bottom_integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	#if state.get_contact_count() < 1:
		#onFloor = true
		#return
	#
	#for i in state.get_contact_count():
		#var norm = state.get_contact_local_normal(i)
		#if norm.dot(Vector2.DOWN) >
	#
	#print(state.get_contact_local_normal(0))
	
	pass
	
	
	
# Possible alternative to integrate forces method of detecting contact points
# https://godotforums.org/d/21368-find-collision-point-of-two-rigidbody2ds
#func is_terrain_under(body: Node):
	#test_move(global_transform, Vector2.ZERO, )


func on_bottom_collision(body: Node):
	if body.is_in_group("terrain"):
		slamming = false
		gliding = false
		linear_velocity *= landingDamp
		bottom.physics_material_override.bounce = 0
		#stick_bottom()
		pass
		
	elif body is Enemy and slamming:
		slamming = false
		gliding = false
		bottom.physics_material_override.bounce = 0		
		body.destroy()
	pass
