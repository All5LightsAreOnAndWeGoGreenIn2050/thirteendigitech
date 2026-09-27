extends Node

const MATCH_TIME = 60.0
const GAME_PAUSE = 1.0
const GAME_OVER_PAUSE = 3.0
const SAVE_PATH = "user://game_scores.json"

enum State { PLAYING, GOAL_PAUSE, GAME_OVER }

var state: int = State.PLAYING
var time_left: float = MATCH_TIME
var scores = {"player": 0, "opponent": 0}
var spawn_player_position: Vector2
var spawn_opponent_position: Vector2

@onready var ball = $Basketball
@onready var player = $Basketball_player
@onready var opponent = $Basketball_opponent
@onready var player_score_label = $HomeLabel
@onready var opponent_score_label = $AwayLabel
@onready var basketball_timer_label = $BasketballTimerLabel
@onready var basketball_timer = $BasketballTimer

func _ready() -> void:
	spawn_player_position = player.position
	spawn_opponent_position = opponent.position
	ball.point_scored.connect(on_point_scored)
	start_game()
	update_scoreboard()
	
	
func _process(delta: float) -> void:
	match state:
		State.PLAYING:
			time_left = maxf(time_left - delta, 0.0)
			basketball_timer_label.text= "Time: %d" % int(ceil(time_left))
			update_scoreboard()
			if time_left <= 0.0:
				end_match()
				
				
func on_point_scored(scorer: String) -> void:
	if state != State.PLAYING:
		return
	scores[scorer] += 1
	state = State.GOAL_PAUSE
	ball.stop()
	set_frozen(true)
	update_scoreboard()
	
	await get_tree().create_timer(GAME_PAUSE).timeout
	
	start_game()
	state = State.PLAYING
	
	
func start_game() -> void:
	player.reset_to(spawn_player_position)
	opponent.reset_to(spawn_opponent_position)
	ball.reset()
	set_frozen(false)
	basketball_timer.wait_time = MATCH_TIME
	basketball_timer.start()
	
	
func end_match() -> void:
	state = State.GAME_OVER
	ball.stop()
	set_frozen(true)
 
	await get_tree().create_timer(GAME_OVER_PAUSE).timeout
 
	save_scores()
	restart_match()
 
 
func restart_match() -> void:
	scores = {"player": 0, "opponent": 0}
	time_left = MATCH_TIME
	start_game()
	update_scoreboard()
	state = State.PLAYING
	
	
func set_frozen(value: bool) -> void:
	player.frozen = value
	opponent.frozen = value
	
	
func update_scoreboard() -> void:
	player_score_label.text = "%d" % scores["player"]
	opponent_score_label.text = "%d" % scores["opponent"]
			
# Saves scores for results screen	
func save_scores() -> void:
	var data = {}
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		data = JSON.parse_string(file.get_as_text())
		file.close()
	
	data["basketball"] = {
		"home_score": scores["player"],
		"away_score": scores["opponent"]
	}
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return
	file.store_string(JSON.stringify(data))
	file.close()


func load_scores() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return {"home_score": 0, "away_score": 0}
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	return data
