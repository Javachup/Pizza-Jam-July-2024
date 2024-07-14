extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://Prototype/Scenes/level1.tscn")
	pass # Replace with function body.


func _on_button_2_pressed():
	get_tree().quit()
	pass # Replace with function body.
	
	
func _on_main_button_pressed():
	get_tree().change_scene_to_file("res://Menus/Main_Menu.tscn")
