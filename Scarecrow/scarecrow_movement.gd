extends RigidBody2D

# States that the scarecrow can be in, mutually exclusive
enum MoveState { IDLE, HOP_CHARGE, SUPER_JUMP_CHARGE } 
var currentMoveState : MoveState = MoveState.IDLE

@export_group("References")
@export var bottom : RigidBody2D
@export var groundDetectPivot : Node2D
@export var groundDetectArea : Area2D

@export_group("Idle Parameters")
@export var idleStraightForce : float = 40000
@export var idleStraightDamp : float = 4000

@export_group("Hop Parameters")
@export var hopRotateSpeed : float = 100
@export var minHopForce : float = 250
@export var maxHopForce : float = 1000
@export var minHopChargeAngle : float = 10
@export var maxHopChargeAngle : float = 45
@export var hopChargePowerCurve : Curve # Between 0 and 1

@export_group("Super Jump Parameters")
@export var superJumpMinChargeTime : float = .5
@export var superJumpMaxChargeTime : float = 2.5
@export var superJumpMinForce : float = 1000
@export var superJumpMaxForce : float = 10000
@export var superJumpForceCurve : Curve # Between 0 and 1

var onGround : bool = false

# Hop vars
var hopChargeDir : int = 0

# Super jump vars
var superJumpChargeTime = 0

	
func _process(delta: float) -> void:
	
	groundDetectPivot.global_rotation = 0 # Make sure ground detect area is always facing downward
	
	match currentMoveState:
		MoveState.IDLE:
			idle(delta)
			
		MoveState.HOP_CHARGE:
			hop_charge()
			
		MoveState.SUPER_JUMP_CHARGE:
			super_jump_charge(delta)
		
	pass
	

func _physics_process(delta: float) -> void:
	
	match currentMoveState:
			
		MoveState.IDLE:
			idle_physics(delta)
			
		MoveState.HOP_CHARGE:
			hop_charge_physics(delta)
			
		MoveState.SUPER_JUMP_CHARGE:
			super_jump_charge_physics(delta)
		
	pass
	
	
func idle(delta : float):
	
	if onGround:
		
		# Check for hop input
		# chargeDir will be -1 for left, 0 for neither / both, 1 for right
		hopChargeDir = int(Input.is_action_just_pressed("right")) - int(Input.is_action_just_pressed("left"))
	
		if hopChargeDir != 0:
			currentMoveState = MoveState.HOP_CHARGE
			return
			
		# Check for super jump input
		if Input.is_action_just_pressed("jump"):
			currentMoveState = MoveState.SUPER_JUMP_CHARGE
			
	pass
	
	
func idle_physics(delta : float):
	
	if onGround:
		bottom.linear_velocity.x = 0
		bottom.angular_velocity = 0
		
		#global_rotation = lerpf(global_rotation, 0, delta * 10)
		
		bottom.global_rotation = 0 	# I hate that I have to do this, it makes it look stiff, but this is the
									# the only way I've found to stop a bug with the scarecrow behaving strangely
									# when landing
		
	else:
	
		bottom.apply_torque(-bottom.global_rotation * idleStraightForce)
		bottom.apply_torque(-bottom.angular_velocity * idleStraightDamp)
	
	pass
	
	
func hop_charge():
	
	if (Input.is_action_just_released("right") and hopChargeDir > 0) or \
		(Input.is_action_just_released("left") and hopChargeDir < 0):
		
		linear_velocity = Vector2.ZERO
		bottom.angular_velocity = 0
		
		# Make sure we actually rotated enough to launch
		if(abs(global_rotation_degrees) >= minHopChargeAngle):		
			jump(Vector2.RIGHT.rotated(bottom.global_rotation) * -hopChargeDir, calculate_hop_force())
			onGround = false			
		
		hopChargeDir = 0
		currentMoveState = MoveState.IDLE
						
	pass
	
	
func hop_charge_physics(delta : float):
	
	if abs(global_rotation_degrees) >= maxHopChargeAngle:
		angular_velocity = 0
		linear_velocity.x = 0
		global_rotation_degrees = clampf(global_rotation_degrees, -maxHopChargeAngle, maxHopChargeAngle)
		
	else:
		apply_torque(hopChargeDir * hopRotateSpeed * delta)
		
	
	
func calculate_hop_force():
	var rotPortion = (abs(global_rotation_degrees) - minHopChargeAngle) / (maxHopChargeAngle - minHopChargeAngle)
	var curveSamp = hopChargePowerCurve.sample(rotPortion)
	return lerpf(minHopForce, maxHopForce, curveSamp)
	
	
func super_jump_charge(delta : float):
	
	superJumpChargeTime += delta
	
	if Input.is_action_just_released("jump"):
		if superJumpChargeTime >= superJumpMinChargeTime:
			jump(Vector2.UP, calculate_super_jump_force())
			
		superJumpChargeTime = 0
		onGround = false
		currentMoveState = MoveState.IDLE
	
	pass
	
	
func super_jump_charge_physics(delta : float):
	pass
	
	
func calculate_super_jump_force():
	var timePortion = (superJumpChargeTime - superJumpMinChargeTime) / (superJumpMaxChargeTime - superJumpMinChargeTime)
	var curveSamp = superJumpForceCurve.sample(timePortion)
	return lerpf(superJumpMinForce, superJumpMaxForce, curveSamp)
	
	
func jump(dir : Vector2, force : float):
	bottom.apply_impulse(dir * force)
	pass
	

# Since terrain will all be on terrain layer, don't need to check collision
func _on_ground_detect_area_body_entered(body: Node2D) -> void:
	onGround = true
	
	
func _on_ground_detect_area_body_exited(body: Node2D) -> void:
	onGround = false
