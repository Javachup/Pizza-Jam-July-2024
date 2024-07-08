extends HBoxContainer

@onready var card_manager = %CardManager

@export var ui_card_scene:PackedScene

var selected_cards:Array[UICard]

func add_card(suit:Card.Suit, rank:int):
	var new_card = ui_card_scene.instantiate() as UICard
	new_card.set_card(suit, rank)
	add_child(new_card)
	new_card.on_toggled_with_self.connect(_on_toggled_with_self)

func delete_selected_cards():
	for c in selected_cards:
		c.queue_free()
	selected_cards.clear()

func _on_toggled_with_self(card:UICard, toggled_on:bool):
	if toggled_on:
		selected_cards.append(card)
	else:
		selected_cards.erase(card)

func _ready():
	for i in 5:
		add_card(randi_range(0,3), randi_range(0,12))

func _on_button_pressed():
	for c in card_manager.blue_cards:
		add_card(c.suit, c.rank)
		c.queue_free()
	card_manager.blue_cards.clear()
