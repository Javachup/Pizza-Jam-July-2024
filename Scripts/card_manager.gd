extends Node2D

@export var card:PackedScene

var blue_cards:Array[Card] = []
var red_cards:Array[Card] = []

func spawn_card(pos:Vector2, suit:Card.Suit, rank:int, team:Card.Team):
	if rank < 0 or rank > 12:
		printerr("Rank must be between 0 and 12!")
		return

	var new_card = card.instantiate() as Card
	new_card.set_card(suit, rank, team)
	new_card.position = pos
	new_card.died.connect(_on_card_died)

	if team == Card.Team.BLUE:
		blue_cards.append(new_card)
	elif team == Card.Team.RED:
		red_cards.append(new_card)

	set_targets()

	add_child(new_card)

func set_targets():
	for c in blue_cards:
		c.set_target(red_cards)
	for c in red_cards:
		c.set_target(blue_cards)

func _unhandled_input(event):
	if event.is_action_pressed("spawn_card"):
		var pos = get_global_mouse_position()
		spawn_card(pos, randi_range(0, 3), randi_range(0, 12), Card.Team.BLUE)

	if event.is_action_pressed("spawn_card_alt"):
		var pos = get_global_mouse_position()
		spawn_card(pos, randi_range(0, 3), randi_range(0, 12), Card.Team.RED)

func _on_card_died(card:Card):
	if card.team == Card.Team.BLUE:
		blue_cards.erase(card)
	elif card.team == Card.Team.RED:
		red_cards.erase(card)

	set_targets()
