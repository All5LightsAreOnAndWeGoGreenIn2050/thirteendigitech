extends Control


func _on_pong_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/pong.tscn")


func _on_archery_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/archery.tscn")
