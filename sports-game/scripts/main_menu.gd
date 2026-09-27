extends Control

# Function that allows the game to start
func _on_start_game_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/sports_menu.tscn")
	
# Function that allows the user to change their settings
func _on_settings_pressed() -> void:
	print("Settings")
	
# Function that allows the user to leave the game
func _on_exit_game_pressed() -> void:
	print("Leave game")
	get_tree().quit()
	

func _on_results_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/results.tscn")
