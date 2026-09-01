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
var next_server = "player"
var accepting_serve: bool = true

# Ready function 
func _ready() -> void:
	update_scoreboard()
	ball.connect("point_scored", Callable(self, "_on_point_scored"))

# Update scoreboard
func _on_point_scored(scorer: String) -> void:
	if not accepting_serve:
		return

	accepting_serve = false
	
	rally = false
	ball.stop()

	if scorer == "player":
		home_score += 1
	else:
		away_score += 1

	update_scoreboard()
	next_server = "opponent" if next_server == "player" else "player"


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
	accepting_serve = true

# Notify serve
func notify_serve(who: String) -> void:
	if rally:
		return

	if who != next_server:
		return

	rally = true
	var serve_left: bool = (who == "opponent")
	ball.launch(serve_left)

	if not accepting_serve or rally:
		return

	print("notify_serve called by: ", who)

# Stops the ball and shows the final score for 4 seconds
func end_game(scorer: String) -> void:
	ball.stop()
	await get_tree().create_timer(4.0).timeout
	home_score = 0
	away_score = 0
	next_server = "player"
	update_scoreboard()
	reset_round()

# Displays the score
func update_scoreboard() -> void:
	home_label.text = str(home_score)
	away_label.text = str(away_score)
