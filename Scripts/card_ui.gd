extends TextureButton
class_name UICard

const TEXTURE_PATH = "res://Art/Playing Cards/"
const SIZE_INCREASE = 50.0
const SIZE_LERP_SPEED = 0.1

var suit:Card.Suit = Card.Suit.BACK
var rank:int # 0=Ace, 12=King

var original_size:int
var target_size:float

func set_card(suit:Card.Suit, rank:int):
	self.suit = suit
	self.rank = rank

	var file_name = "card-"
	file_name += Card.suit_to_string[suit] + "-"
	file_name += str(rank+1) + ".png"

	var texture = load(TEXTURE_PATH + file_name)
	texture_normal = texture
	texture_hover = texture
	texture_pressed = texture

func _ready():
	original_size = custom_minimum_size.x
	target_size = original_size

func _on_toggled(toggled_on):
	if toggled_on:
		target_size = original_size + SIZE_INCREASE
	else:
		target_size = original_size

func _process(_delta):
	custom_minimum_size.x = lerp(custom_minimum_size.x, target_size, SIZE_LERP_SPEED)
