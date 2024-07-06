extends CharacterBody2D
class_name Card

enum Suit { BACK = -1, CLUBS, DIAMONDS, HEARTS, SPADES }
const suit_to_string = { Suit.BACK: "back", Suit.CLUBS: "clubs", Suit.DIAMONDS: "diamonds", Suit.HEARTS: "hearts", Suit.SPADES: "spades"}

enum Team { NONE = -1, BLUE, RED, GREEN, YELLOW }

const SPEED = 300.0
const CLOSEST_DIST = 50.0

@onready var sprite = %AnimatedSprite2D

var suit:Suit = Suit.BACK
var rank:int # 0=Ace, 12=King
var team:Team

var target:Card

func update_card():
	sprite.play(suit_to_string[suit])
	sprite.frame = rank

func set_target(potential_targets:Array[Card]):
		var closest_dist = INF
		var closest_card:Card = null
		for c in potential_targets:
			var dist = (position - c.position).length()
			if dist < closest_dist:
				closest_dist = dist
				closest_card = c
		target = closest_card

func _ready():
	update_card()

func _physics_process(delta):
	if target == null: return

	var dir = target.position - position
	if dir.length_squared() > CLOSEST_DIST * CLOSEST_DIST:
		velocity = dir.normalized() * SPEED
	else:
		velocity = Vector2.ZERO

	move_and_slide()
