extends Control


func resume():
	get_tree().paused = false
	visible = false	
	
	
func pause():
	get_tree().paused = true
	visible = true

	
func testP():
	if Input.is_action_just_pressed("pause") and get_tree().paused == false:
		pause()
	elif Input.is_action_just_pressed("pause") and get_tree().paused == true:
		resume()
		
		
func _on_resume_pressed() -> void:
	resume()
	
	
func _on_return_to_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_exit_game_pressed() -> void:
	get_tree().quit()
	
	
func _process(delta) -> void:
	testP()
