extends RigidBody2D

@export var bottom : RigidBody2D
@export var groundDetectArea : Area2D

@export var hopRotateSpeed : float = 100
@export var topHopForce : float = 500
@export var bottomHopForce : float = 750

enum MoveState { IDLE, HOP_CHARGE }

var currentMoveState : MoveState = MoveState.IDLE

var onGround : bool = false

var chargeDir : int = 0

var prevFrameBottomAngle : float = 0
	
	
	
func _process(delta: float) -> void:
		
	update_on_ground()
	
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
	
	
func idle(delta : float):
	
	lock_rotation = false
	
	if onGround:
		# chargeDir will be -1 for left, 0 for neither / both, 1 for right
		chargeDir = int(Input.is_action_just_pressed("right")) - int(Input.is_action_just_pressed("left"))
	
		if chargeDir != 0:
			currentMoveState = MoveState.HOP_CHARGE
	
	pass
	
	
func idle_physics(delta : float):
	
	#bottom.apply_torque(-bottom.global_rotation * 10000)
	#bottom.angular_damp = 10000 / abs(bottom.global_rotation)
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
				
	pass
	
	
func hop_charge_physics(delta : float):
	apply_force((Vector2.RIGHT * chargeDir).rotated(bottom.global_rotation) * hopRotateSpeed * delta)	
	
	
func update_on_ground():
	#onGround = groundDetectionRaycast.is_colliding()
	onGround = groundDetectArea.get_overlapping_bodies().size() != 0
	pass
	
	
func hop(dir : Vector2, force : float):
	apply_impulse(dir * force)
	pass
	
	
func jump(dir : Vector2, force : float):
	bottom.apply_impulse(dir * force)
	pass
