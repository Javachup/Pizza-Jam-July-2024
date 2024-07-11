extends RigidBody2D

@export var bottom : RigidBody2D
@export var groundDetectPivot : Node2D
@export var groundDetectArea : Area2D

@export var hopRotateSpeed : float = 100
@export var topHopForce : float = 500
@export var bottomHopForce : float = 750

enum MoveState { IDLE, HOP_CHARGE }

var currentMoveState : MoveState = MoveState.IDLE

var onGround : bool = false

var chargeDir : int = 0

var prevFrameBottomAngle : float = 0

var wasOnGroundPrevFrame : bool = false

var detectGroundBuffer : float = .2
	
	
	
func _process(delta: float) -> void:
	
	wasOnGroundPrevFrame = onGround
	detectGroundBuffer -= delta
	
	#print(detectGroundBuffer)
	
	update_on_ground()
	
	groundDetectPivot.global_rotation = 0
	
	match currentMoveState:
		MoveState.IDLE:
			idle(delta)
			
		MoveState.HOP_CHARGE:
			hop_charge()
		
	pass
	

func _physics_process(delta: float) -> void:
	
	match currentMoveState:
			
		MoveState.IDLE:
			idle_physics(delta)
			
		MoveState.HOP_CHARGE:
			hop_charge_physics(delta)
		
	pass
	
	
func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if currentMoveState == MoveState.IDLE:
		
		if onGround and detectGroundBuffer < 0:
			print("here")
			bottom.linear_velocity.x = 0
			bottom.angular_velocity = 0
			bottom.rotation = 0
		
		pass
		#state.apply_torque(-bottom.global_rotation * 40000)
		#bottom.angular_damp = (2 * PI - abs(bottom.global_rotation)) * 100
		#if abs(bottom.global_rotation_degrees) < 1:
			#bottom.lock_rotation = true
	#else:
		#bottom.lock_rotation = false
	pass
	
	
func idle(delta : float):
	
	if onGround:
		# chargeDir will be -1 for left, 0 for neither / both, 1 for right
		chargeDir = int(Input.is_action_just_pressed("right")) - int(Input.is_action_just_pressed("left"))
	
		if chargeDir != 0:
			currentMoveState = MoveState.HOP_CHARGE
			bottom.angular_damp = 0
			
	pass
	
	
func idle_physics(delta : float):
	
	bottom.apply_torque(-bottom.global_rotation * 40000)
	bottom.apply_torque(-bottom.angular_velocity * 4000)
	
	#bottom.angular_damp = (2 * PI - abs(bottom.global_rotation)) * 100
	
	
	
	#if onGround:
		#bottom.angular_velocity = 0
		
	#bottom.angular_damp = INF
	#
	#apply_force(Vector2.UP * 10000)
	#bottom.apply_force(Vector2.DOWN * 10000)
	
	#var prevSign = sign(prevFrameBottomAngle)
	#var currSign = sign(bottom.global_rotation)
	#
	#if prevSign != currSign:
		#bottom.global_rotation = 0
		#bottom.angular_velocity = 0
		#bottom.lock_rotation = true
		#
	#else:
		#bottom.lock_rotation = false
	#
	#print(bottom.angular_damp)
	
	prevFrameBottomAngle = bottom.global_rotation
	
	pass
	
	
func hop_charge():
	
	if (Input.is_action_just_released("right") and chargeDir > 0) or \
		(Input.is_action_just_released("left") and chargeDir < 0):
		
		linear_velocity = Vector2.ZERO
		bottom.angular_velocity = 0
		
		#jump(Vector2.UP.rotated(bottom.global_rotation), 1000)
		#hop(Vector2.RIGHT.rotated(bottom.global_rotation) * -chargeDir, topHopForce)
		jump(Vector2.RIGHT.rotated(bottom.global_rotation) * -chargeDir, bottomHopForce)
		
		chargeDir = 0
		currentMoveState = MoveState.IDLE
		
		detectGroundBuffer = .2
				
	pass
	
	
func hop_charge_physics(delta : float):
	apply_force((Vector2.RIGHT * chargeDir).rotated(bottom.global_rotation) * hopRotateSpeed * delta)	
	
	
func update_on_ground():
	#onGround = groundDetectionRaycast.is_colliding()
	if detectGroundBuffer > 0:
		onGround = false
		return
	onGround = groundDetectArea.get_overlapping_bodies().size() != 0
	pass
	
	
func hop(dir : Vector2, force : float):
	apply_impulse(dir * force)
	pass
	
	
func jump(dir : Vector2, force : float):
	bottom.apply_impulse(dir * force)
	pass
