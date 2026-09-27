extends Control


func _on_pong_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/pong.tscn")


func _on_archery_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/archery_scene.tscn")


func _on_football_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/football_scene.tscn")


func _on_basketball_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/basketball_scene.tscn")
