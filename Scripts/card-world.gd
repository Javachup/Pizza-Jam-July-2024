extends CharacterBody2D

enum Suit { BACK = -1, CLUBS, DIAMONDS, HEARTS, SPADES }
const suit_to_string = { Suit.BACK: "back", Suit.CLUBS: "clubs", Suit.DIAMONDS: "diamonds", Suit.HEARTS: "hearts", Suit.SPADES: "spades"}

const SPEED = 300.0

@onready var sprite = %AnimatedSprite2D

var suit:Suit = Suit.BACK
var rank:int # 0=Ace, 12=King

func update_card():
	sprite.play(suit_to_string[suit])
	sprite.frame = rank

func _ready():
	suit = randi_range(0, 3)
	rank = randi_range(0, 12)
	update_card()

func _physics_process(delta):
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
