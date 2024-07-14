extends Area2D


func _on_body_entered(body: Node2D) -> void:
	get_tree().call_deferred("change_scene_to_file", "res://Menus/win_screen.tscn")
	#get_tree().change_scene_to_file("res://Menus/win_screen.tscn")
