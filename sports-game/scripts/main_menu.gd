extends Control

# Function that allows the game to start
func _on_start_game_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/pong.tscn")
	print("Game started")
	
# Function that allows the player to select their character
func _on_character_selection_pressed() -> void:
	print("Select Character")
	
# Function that allows the user to change their settings
func _on_settings_pressed() -> void:
	print("Settings")
	
# Function that allows the user to leave the game
func _on_exit_game_pressed() -> void:
	print("Leave game")
	get_tree().quit()
	
