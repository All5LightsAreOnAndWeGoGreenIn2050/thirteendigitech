extends Node

const MATCH_TIME = 60.0
const GAME_PAUSE = 1.0
const GAME_OVER_PAUSE = 3.0

enum State { PLAYING, GOAL_PAUSE, GAME_OVER }

var state: int = State.PLAYING
var time_left: float = MATCH_TIME
var scores = {"player": 0, "opponent": 0}
var spawn_player_position: Vector2
var spawn_opponent_position: Vector2

@onready var ball = $Soccer_Ball
@onready var player = $football_player
@onready var opponent = $football_opponent
@onready var player_score_label = $"../PlayerScoreLabel"
@onready var opponent_score_label = $"../OpponentScoreLabel"

func _ready() -> void:
	spawn_player_position = player.position
	spawn_opponent_position = opponent.position
	ball.point_scored.connect(on_point_scored)
	kickoff()
	update_scoreboard()
	
	
func _process(delta: float) -> void:
	match state:
		State.PLAYING:
			time_left = maxf(time_left - delta, 0.0)
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
	
	kickoff()
	state = State.PLAYING
	
	
func kickoff() -> void:
	player.reset_to(spawn_player_position)
	opponent.reset_to(spawn_opponent_position)
	ball.reset()
	set_frozen(false)
	
	
func end_match() -> void:
	state = State.GAME_OVER
	ball.stop()
	set_frozen(true)
 
	await get_tree().create_timer(GAME_OVER_PAUSE).timeout
 
	restart_match()
 
 
func restart_match() -> void:
	scores = {"player": 0, "opponent": 0}
	time_left = MATCH_TIME
	kickoff()
	update_scoreboard()
	state = State.PLAYING
	
	
func set_frozen(value: bool) -> void:
	player.frozen = value
	opponent.frozen = value
	
	
func update_scoreboard() -> void:
	player_score_label.text = "%d" % scores["player"]
	opponent_score_label.text = "%d" % scores["opponent"]
			
