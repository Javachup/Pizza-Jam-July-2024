extends RigidBody2D

@export var bottom : RigidBody2D
@export var groundDetectPivot : Node2D
@export var groundDetectArea : Area2D

@export var idleStraightForce : float = 40000
@export var idleStraightDamp : float = 4000

@export var hopRotateSpeed : float = 100
@export var minHopForce : float = 250
@export var maxHopForce : float = 1000
@export var minHopChargeAngle : float = 10
@export var maxHopChargeAngle : float = 45
@export var hopChargePowerCurve : Curve # Between 0 and 1

enum MoveState { IDLE, HOP_CHARGE }

var currentMoveState : MoveState = MoveState.IDLE

var onGround : bool = false

var hopChargeDir : int = 0

	
func _process(delta: float) -> void:
	
	groundDetectPivot.global_rotation = 0 # Make sure ground detect area is always facing downward
	
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
	pass
	
	
func idle(delta : float):
	
	if onGround:
		# chargeDir will be -1 for left, 0 for neither / both, 1 for right
		hopChargeDir = int(Input.is_action_just_pressed("right")) - int(Input.is_action_just_pressed("left"))
	
		if hopChargeDir != 0:
			currentMoveState = MoveState.HOP_CHARGE
			
	pass
	
	
func idle_physics(delta : float):
	
	if onGround:
		bottom.linear_velocity.x = 0
		bottom.angular_velocity = 0
		bottom.rotation_degrees = 0
		
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
	
	
func hop(dir : Vector2, force : float):
	apply_impulse(dir * force)
	pass
	
	
func jump(dir : Vector2, force : float):
	bottom.apply_impulse(dir * force)
	pass
	

# Since terrain will all be on terrain layer, don't need to check collision
func _on_ground_detect_area_body_entered(body: Node2D) -> void:
	onGround = true
	
	
func _on_ground_detect_area_body_exited(body: Node2D) -> void:
	onGround = false
