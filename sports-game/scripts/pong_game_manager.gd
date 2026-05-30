extends Node

const WIN_SCORE = 11

@onready var ball = %PingPongBall
@onready var player = %Player
@onready var opponent = %Opponent
@onready var home_label = %HomePoint
@onready var away_label = %AwayPoint

var home_score = 0
var away_score = 0
var rally = false
var last_scorer = ""
# Ready function 
func _ready() -> void:
	update_scoreboard()
	ball.connect("point_scored", Callable(self, "_on_point_scored"))

# Update scoreboard
func _on_point_scored(scorer: String) -> void:
	rally = false
	ball.stop()
	last_scorer = scorer

	if scorer == "player":
		home_score += 1
	else:
		away_score += 1

	update_scoreboard()

	if home_score >= WIN_SCORE or away_score >= WIN_SCORE:
		end_game(scorer)
	else:
		await get_tree().create_timer(1.5).timeout
		reset_round()

# Reset every round code
func reset_round() -> void:
	ball.reset()
	player.reset()
	opponent.reset()
	rally = false

# Notify serve
func notify_serve(who: String) -> void:
	if rally:
		return # Exit the function if rally is happening
	var correct_server: String = "opponent" if last_scorer == "player" else "player"
	if who != correct_server:
		return # Exit the function if wrong person is serving
	rally = true
	# Determine the direction the ball launches + Trigger Hit animation
	var serve_left: bool = (who == "player")
	ball.launch(serve_left)
	if who == "player":
		player.trigger_hit_animation()
	else:
		opponent.trigger_hit_animation()

	print("notify_serve called by: ", who)

# Stops the ball and shows the final score for 4 seconds
func end_game(scorer: String) -> void:
	ball.stop()
	await get_tree().create_timer(4.0).timeout
	home_score = 0
	away_score = 0
	last_scorer = ""
	update_scoreboard()
	reset_round()

# Displays the score
func update_scoreboard() -> void:
	home_label.text = str(home_score)
	away_label.text = str(away_score)
