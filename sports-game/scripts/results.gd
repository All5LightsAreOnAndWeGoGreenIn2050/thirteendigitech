extends Node2D

const SAVE_PATH = "user://game_scores.json"

func _ready() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		print("No saved scores found")
		return
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	
	if data.has("pong"):
		$Pong/PongHome.text = "HOME: %s" % str(data["pong"]["home_score"])
		$Pong/PongAway.text = "AWAY: %s" % str(data["pong"]["away_score"])
	
	if data.has("basketball"):
		$Basketball/BasketballHome.text = "HOME: %s" % str(data["basketball"]["home_score"])
		$Basketball/BasketballAway.text = "AWAY: %s" % str(data["basketball"]["away_score"])
		
	if data.has("football"):
		$Football/FootballHome.text = "HOME: %s" % str(data["football"]["home_score"])
		$Football/FootballAway.text = "AWAY: %s" % str(data["football"]["away_score"])
		
	if data.has("archery"):
		$Archery/ArcheryHome.text = "HOME: %s" % str(data["archery"]["home_score"])
		$Archery/ArcheryAway.text = "AWAY: %s" % str(data["archery"]["away_score"])
		
		
func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
