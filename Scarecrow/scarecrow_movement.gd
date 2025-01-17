class_name Scarecrow

extends RigidBody2D

# States that the scarecrow can be in, mutually exclusive
enum MoveState { IDLE, HOP_CHARGE, SUPER_JUMP_CHARGE, GLIDE, STOMP } 
var currentMoveState : MoveState = MoveState.IDLE :
	set(value):
		if value != currentMoveState:
			_on_move_state_changed(currentMoveState, value)
			currentMoveState = value

@onready var anim_sprite = %AnimatedSprite2D
@onready var anim_player = %AnimationPlayer
# Audio
@onready var glide_audio = %Glide
@onready var charge_jump_audio = %ChargeJump
@onready var jump_audio = %Jump
@onready var hit_audio = %Hit
@onready var stomp_audio = %Stomp

@export_group("References")
@export var groundDetectPivot : Node2D
@export var groundDetectArea : Area2D
@export var health : Health
@export var healthBar : ProgressBar

@export_group("Idle Parameters")
@export var idleStraightForce : float = 40000
@export var idleStraightDamp : float = 4000
@export var inAirControl : float = 4000
@export var slipperyFactor : float = 2 # Higher the number, higher the slowdown while on ground

@export_group("Hop Parameters")
@export var hopRotateSpeed : float = 100
@export var minHopForce : float = 250
@export var maxHopForce : float = 1000
@export var minHopChargeAngle : float = 10
@export var maxHopChargeAngle : float = 45
@export var hopChargePowerCurve : Curve # Between 0 and 1
@export var minHopAngleAdjustment = 10
@export var maxHopAngleAdjustment = 40
@export var maxHopReboundMult = 50 
@export var verticalHopForce = 100 # The base upward force when hopping

@export_group("Super Jump Parameters")
@export var superJumpMinChargeTime : float = .5
@export var superJumpMaxChargeTime : float = 2.5
@export var superJumpMinForce : float = 1000
@export var superJumpMaxForce : float = 10000
@export var superJumpForceCurve : Curve # Between 0 and 1

@export_group("Glide Parameters")
@export var glideSpeed : float = 100
@export var glideGravityMult : float = .2

@export_group("Stomp Parameters")
@export var stompSpeed : float = 1000
@export var stompDamage : int = 100
@export var stompBounceOffEnemyForce : float = 500

@export_group("Misc")
@export var iFrameTime : float = 3
@export var iFrameFlashTime : float = .2

var onGround : bool = false

# Idle vars
var ogFriction : float = 0

# Hop vars
var hopChargeDir : int = 0

# Super jump vars
var superJumpChargeTime = 0

# Glide vars
var ogGravity : float = 0

var hoppedThisFrame : bool = false

var iFrameTimePassed : float = 0
var iFrameFlashTimePassed : float = 0


func _ready() -> void:
	ogGravity = gravity_scale
	ogFriction = physics_material_override.friction
	iFrameTimePassed = iFrameTime
	
	healthBar.min_value = 0
	healthBar.max_value = health.max_health
	
func _process(delta: float) -> void:
	
	groundDetectPivot.global_rotation = 0 # Make sure ground detect area is always facing downward
	iFrameTimePassed += delta
	healthBar.value = health.health
	
	print(MoveState.keys()[currentMoveState])
	print(onGround)
	
	if iFrameTimePassed < iFrameTime:
		if iFrameFlashTimePassed >= iFrameFlashTime:
			anim_sprite.visible = !anim_sprite.visible
			iFrameFlashTimePassed = 0
		else:
			iFrameFlashTimePassed += delta
		pass
		
	else:
		anim_sprite.visible = true
		iFrameFlashTimePassed = iFrameFlashTime
	
	match currentMoveState:
		MoveState.IDLE:
			idle(delta)
			
		MoveState.HOP_CHARGE:
			hop_charge()
			
		MoveState.SUPER_JUMP_CHARGE:
			super_jump_charge(delta)
			
		MoveState.GLIDE:
			glide(delta)
			
		MoveState.STOMP:
			stomp(delta)
		
	pass
	

func _physics_process(delta: float) -> void:
	
	match currentMoveState:
			
		MoveState.IDLE:
			idle_physics(delta)
			
		MoveState.HOP_CHARGE:
			hop_charge_physics(delta)
			
		MoveState.SUPER_JUMP_CHARGE:
			super_jump_charge_physics(delta)
			
		MoveState.GLIDE:
			glide_physics(delta)
			
		MoveState.STOMP:
			stomp_physics(delta)
		
	pass
	
	
func idle(_delta : float):
	
	if onGround:
		
		physics_material_override.friction = ogFriction
		
		# Check for hop input
		# chargeDir will be -1 for left, 0 for neither / both, 1 for right
		hopChargeDir = int(Input.is_action_just_pressed("right")) - int(Input.is_action_just_pressed("left"))
	
		if hopChargeDir != 0:
			anim_sprite.flip_h = hopChargeDir > 0
			currentMoveState = MoveState.HOP_CHARGE
			return
			
		# Check for super jump input
		if Input.is_action_just_pressed("jump"):
			currentMoveState = MoveState.SUPER_JUMP_CHARGE
			return
	
	else:
		physics_material_override.friction = 0
		
		# Check for glide input
		if linear_velocity.y > 0 and Input.is_action_pressed("glide"):
			currentMoveState = MoveState.GLIDE
			return
			
		if Input.is_action_just_pressed("stomp"):
			currentMoveState = MoveState.STOMP
			linear_velocity = Vector2.ZERO
			linear_velocity.y = stompSpeed
			return
			
	pass
	
	
func idle_physics(delta : float):
	
	if onGround and !hoppedThisFrame:
		apply_torque(-global_rotation * idleStraightForce)
		apply_torque(-angular_velocity * idleStraightDamp)
		linear_velocity.x /= 1 + (delta * slipperyFactor)
		#angular_velocity = 0
		#linear_velocity = Vector2.ZERO
		pass
		#linear_velocity.x = 0
		#angular_velocity = 0
		
		#global_rotation = lerpf(global_rotation, 0, delta * 10)
		
		#global_rotation = 0 	# I hate that I have to do this, it makes it look stiff, but this is the
									# the only way I've found to stop a bug with the scarecrow behaving strangely
									# when landing
		
	else:
		var input := int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
		anim_sprite.flip_h = input < 0
		apply_force(Vector2.RIGHT * input * inAirControl * delta)
		pass
	
	apply_torque(-global_rotation * idleStraightForce)
	apply_torque(-angular_velocity * idleStraightDamp)
	
	hoppedThisFrame = false
	
	pass
	
	
func hop_charge():
						
	pass
	
	
func hop_charge_physics(delta : float):
	
	if (!Input.is_action_pressed("right") and hopChargeDir > 0 and sign(global_rotation) == hopChargeDir) or \
		(!Input.is_action_pressed("left") and hopChargeDir < 0 and sign(global_rotation) == hopChargeDir):
		
		linear_velocity = Vector2.ZERO
		angular_velocity = 0
		
		# Make sure we actually rotated enough to launch
		if(abs(global_rotation_degrees) >= minHopChargeAngle):
			#var dir : Vector2 = Vector2.RIGHT.rotated(global_rotation + 15 * -sign(global_rotation))
			var dir : Vector2 = Vector2.RIGHT.rotated(-abs(global_rotation))
			
			dir.x *= -sign(hopChargeDir)
				
			#var anglePortion = lerpf(minHopChargeAngle, maxHopChargeAngle, 1 - calculate_hop_rot_portion())
			dir = dir.rotated(deg_to_rad(lerpf(minHopAngleAdjustment, maxHopAngleAdjustment, \
				1 - calculate_hop_rot_portion())) * hopChargeDir)
			
			
			jump(dir, calculate_hop_force())
			jump(Vector2.UP, verticalHopForce)
			onGround = false
			hoppedThisFrame = true
			
		else:
			global_rotation = 0
		
		hopChargeDir = 0
		currentMoveState = MoveState.IDLE
		
		return
		
	if !Input.is_action_pressed("right") and !Input.is_action_pressed("left"):
		
		hopChargeDir = 0
		currentMoveState = MoveState.IDLE
		
		return
	
	if abs(global_rotation_degrees) >= maxHopChargeAngle and sign(global_rotation_degrees) == hopChargeDir:
		angular_velocity = 0
		linear_velocity.x = 0
		global_rotation_degrees = clampf(global_rotation_degrees, -maxHopChargeAngle, maxHopChargeAngle)
		
	else:
		
		var force = Vector2.RIGHT * hopChargeDir * hopRotateSpeed * delta
		#var force = Vector2.RIGHT.rotated(global_rotation) * hopChargeDir * hopRotateSpeed * delta
		
		#if sign(global_rotation) == hopChargeDir:
			#force *= 1
	
		#if sign(global_rotation) != hopChargeDir:
			#force.y *= -1
			
		#tempSprite.global_position = (global_position + Vector2(0, -100).rotated(global_rotation)) + force.rotated(global_rotation)
		
		var reboundMult = 1
		if sign(global_rotation) != hopChargeDir:
			reboundMult = maxHopReboundMult * lerpf(1.0 / maxHopReboundMult, 1, abs(global_rotation_degrees) / 90)
			#print(i)
			#force *= 100
		#apply_torque(force.rotated(global_rotation).length() * hopChargeDir * i)
		apply_force(force.rotated(global_rotation) * reboundMult, Vector2(0, -100).rotated(global_rotation))
		
		#print(global_rotation_degrees)
		#print(sign(global_rotation))
		
		#print(angular_velocity)
		#print(force.rotated(global_rotation).length() * hopChargeDir * i)
		#print(force)
		
		#print(Vector2.RIGHT.rotated(global_rotation) * hopChargeDir)
	
	#print(global_rotation_degrees)
		
		
func calculate_hop_rot_portion():
	
	var rotPortion = (abs(global_rotation_degrees) - minHopChargeAngle) / (maxHopChargeAngle - minHopChargeAngle)
	return rotPortion
	
	
func calculate_hop_force():
	var rotPortion = calculate_hop_rot_portion()
	var curveSamp = hopChargePowerCurve.sample(rotPortion)
	return lerpf(minHopForce, maxHopForce, curveSamp)
	
	
func super_jump_charge(delta : float):
	
	superJumpChargeTime += delta
	
	if Input.is_action_just_released("jump"):
		if superJumpChargeTime >= superJumpMinChargeTime:
			jump(Vector2.UP, calculate_super_jump_force())
			onGround = false			
			
		superJumpChargeTime = 0
		currentMoveState = MoveState.IDLE
	
	pass
	
	
func super_jump_charge_physics(_delta : float):
	apply_torque(-global_rotation * idleStraightForce * 10)
	apply_torque(-angular_velocity * idleStraightDamp * 10)
	pass
	
	
func calculate_super_jump_force():
	var timePortion = (superJumpChargeTime - superJumpMinChargeTime) / (superJumpMaxChargeTime - superJumpMinChargeTime)
	var curveSamp = superJumpForceCurve.sample(timePortion)
	return lerpf(superJumpMinForce, superJumpMaxForce, curveSamp)
	
	
func glide(_delta : float):
	
	gravity_scale = ogGravity * glideGravityMult # Not best practice, but I don't have time to make
													# a nice state machine system with enter / exit :(
	pass
	
	
func glide_physics(delta : float):
	
	if Input.is_action_just_released("glide") or onGround:
		currentMoveState = MoveState.IDLE
		gravity_scale = ogGravity
		angular_velocity = 0
		
		if onGround:
			linear_velocity.x = 0
		
		return
	
	var inputDir = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
	anim_sprite.flip_h = inputDir < 0
	apply_force(Vector2.RIGHT * inputDir * glideSpeed * delta)
	
	pass
	
	
func stomp(_delta : float):
	pass
	
	
func stomp_physics(_delta : float):
	
	if onGround:
		currentMoveState = MoveState.IDLE
	
	pass
	
	
func jump(dir : Vector2, force : float):
	apply_impulse(dir * force)
	pass
	
	
func on_die():
	get_tree().call_deferred("change_scene_to_file", "res://Menus/lose_screen.tscn")
	#get_tree().change_scene_to_file("res://Menus/lose_screen.tscn")
	pass
	

# Since terrain will all be on terrain layer, don't need to check collision
func _on_ground_detect_area_body_entered(_body: Node2D) -> void:
	onGround = true
	
	
func _on_ground_detect_area_body_exited(_body: Node2D) -> void:
	onGround = false


func _on_hurt_box_body_entered(body: Node2D) -> void:
	
	if body is SeedBullet and iFrameTimePassed >= iFrameTime:
		var bullet = body as SeedBullet
		health.take_damage(bullet.damage)
		
		bullet.queue_free()
		
		iFrameTimePassed = 0
	
	pass # Replace with function body.


func _on_hurt_box_area_entered(area: Area2D) -> void:
	
	if currentMoveState == MoveState.STOMP:
		return
	
	if area is MelonRoller and iFrameTimePassed >= iFrameTime:
		var melonRoller = area as MelonRoller
		health.take_damage(melonRoller.damage)
		
		iFrameTimePassed = 0

func _on_move_state_changed(previous_state:MoveState, new_state:MoveState):
	match new_state:
		MoveState.IDLE:
			anim_sprite.play("idle")
		MoveState.GLIDE:
			anim_sprite.play("glide")
			glide_audio.play()
		MoveState.SUPER_JUMP_CHARGE:
			anim_player.play("Charge")
			charge_jump_audio.play()
		MoveState.STOMP:
			jump_audio.stop()
	
	match previous_state:
		MoveState.SUPER_JUMP_CHARGE:
			anim_player.play("Jump")
			charge_jump_audio.stop()
			jump_audio.play()
		MoveState.GLIDE:
			glide_audio.stop()
		MoveState.HOP_CHARGE:
			jump_audio.play()
		MoveState.STOMP:
			stomp_audio.play()

func _on_health_on_damage():
	hit_audio.play()

func _on_hit_box_area_entered(area: Area2D) -> void:
	if currentMoveState != MoveState.STOMP:
		return
	
	area.health.take_damage(stompDamage)
	linear_velocity.y = 0
	apply_force(stompBounceOffEnemyForce * Vector2.UP)
	
	pass # Replace with function body.
