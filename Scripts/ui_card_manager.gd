extends HBoxContainer

@export var ui_card_scene:PackedScene

func _ready():
	for i in 5:
		var new_card = ui_card_scene.instantiate() as UICard
		new_card.set_card(randi_range(0,3), randi_range(0,12))
		add_child(new_card)
