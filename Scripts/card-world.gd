extends CharacterBody2D
class_name Card

enum Suit { BACK = -1, CLUBS, DIAMONDS, HEARTS, SPADES }
const suit_to_string = { Suit.BACK: "back", Suit.CLUBS: "clubs", Suit.DIAMONDS: "diamonds", Suit.HEARTS: "hearts", Suit.SPADES: "spades"}

enum Team { NONE = -1, BLUE, RED, GREEN, YELLOW }

const SPEED = 300.0
const CLOSEST_DIST = 50.0

@onready var sprite = %AnimatedSprite2D
@onready var attack_area = %Attack
@onready var attack_timer = %AttackTimer

var suit:Suit = Suit.BACK
var rank:int # 0=Ace, 12=King
var team:Team

var health := 100.0
var is_dead:bool :
	get: return health < 0
var attack_damage := 100.0

var can_attack := true

var target:Card

signal died(card:Card)

func damage(damage:float):
	if is_dead: return

	health -= damage

	if is_dead:
		update_card()
		died.emit(self)

func set_card(suit:Suit, rank:int, team:Team):
	self.suit = suit
	self.rank = rank
	self.team = team

func update_card():
	if is_dead:
		sprite.play("back")
		sprite.frame = team
	else:
		sprite.play(suit_to_string[suit])
		sprite.frame = rank

	if team == Team.BLUE:
		set_collision_layer_value(1, true)
		attack_area.set_collision_mask_value(2, true)

	elif team == Team.RED:
		set_collision_layer_value(2, true)
		attack_area.set_collision_mask_value(1, true)

	else: printerr("No team!")

func set_target(potential_targets:Array[Card]):
		var closest_dist = INF
		var closest_card:Card = null
		for c in potential_targets:
			var dist = (position - c.position).length()
			if dist < closest_dist:
				closest_dist = dist
				closest_card = c
		target = closest_card

func attack(target:Vector2):
	print("attack!")
	attack_area.look_at(target)

	for c in attack_area.get_overlapping_bodies():
		if c is Card:
			c.damage(attack_damage)

	can_attack = false
	attack_timer.start()

func _ready():
	update_card()

func _physics_process(delta):
	if is_dead: return
	if target == null: return

	var dir = target.position - position
	if dir.length_squared() > CLOSEST_DIST * CLOSEST_DIST:
		velocity = dir.normalized() * SPEED
	else:
		velocity = Vector2.ZERO
		if can_attack:
			attack(target.position)

	move_and_slide()

func _on_attack_timer_timeout():
	can_attack = true
