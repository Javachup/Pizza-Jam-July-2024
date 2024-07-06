extends TextureButton
class_name UICard

const TEXTURE_PATH = "res://Art/Playing Cards/"

var suit:Card.Suit = Card.Suit.BACK
var rank:int # 0=Ace, 12=King

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

func _on_toggled(toggled_on):
	pass # Replace with function body.
