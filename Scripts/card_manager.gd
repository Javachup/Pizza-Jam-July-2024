extends Node2D

@onready var ui_card_manager = %UICardManager

@export var card:PackedScene

const MAX_SPAWN_DIST = 50

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
		for c in ui_card_manager.selected_cards:
			var rand_angle = randf_range(0, TAU)
			var rand_dist = randf_range(0, MAX_SPAWN_DIST)
			var rand_offset = Vector2.from_angle(rand_angle) * rand_dist
			spawn_card(pos + rand_offset, c.suit, c.rank, Card.Team.BLUE)
		ui_card_manager.delete_selected_cards()

	if event.is_action_pressed("spawn_card_alt"):
		var pos = get_global_mouse_position()
		spawn_card(pos, randi_range(0, 3), randi_range(0, 12), Card.Team.RED)

func _on_card_died(card:Card):
	if card.team == Card.Team.BLUE:
		blue_cards.erase(card)
	elif card.team == Card.Team.RED:
		red_cards.erase(card)

	set_targets()
