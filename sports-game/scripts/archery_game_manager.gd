extends Node


const total_time: float = 60.0
const min_targets: int = 1.0
const max_targets: int = 10.0

@export var target_scene: PackedScene

@onready var player_archery = $Player
@onready var opponent_archery = $Opponent
@onready var home_archery_label = $PlayerScore
@onready var away_archery_label = $OpponentScore
@onready var game_timer = $GameTimer
@onready var game_timer_label = $GameTimerLabel

var archery_player_score: int = 0
var archery_opponent_score: int = 0
var time_left: float = total_time
var game_activated: bool = false
var targets_spawning: Array = []

func _ready() -> void:
	target_spawning()
	player_archery.register_targets(targets_spawning)
	opponent_archery.register_targets(targets_spawning)
	start_game()


func start_game():
	game_activated = true
	game_timer.wait_time = total_time
	game_timer.one_shot = true
	game_timer.start()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not game_activated:
		return
	time_left = max(0.0, time_left -delta)
	game_timer_label.text= "Time: %d" % int(ceil(time_left))
	
	
func target_spawning() -> void:
	var count = randi_range(min_targets, max_targets)
	var viewportsize = get_tree().root.get_visible_rect().size
	var margin = Vector2(150,120)
	var y_min = margin.y
	var y_max = viewportsize.y - 200.0
	
	for i in count:
		var targets = target_scene.instantiate()
		targets.position = Vector2(
			randf_range(margin.x, viewportsize.x - margin.x),
			randf_range(y_min, y_max)
		)
		targets.hit.connect(on_target_hit.bind(targets))
		targets.add_to_group("targets")
		add_child(targets)
		targets_spawning.append(targets)
		
	
func on_target_hit(points: int, shooter: String, target: Node2D) -> void:
	if not game_activated:
		return
	if shooter == "player":
		archery_player_score += points
		home_archery_label.text = "%d" % archery_player_score
	else:
		archery_opponent_score += points
		away_archery_label.text = "%d" % archery_opponent_score
		
	print("on_target_hit called, points: ", points, " shooter: ", shooter)
		
		
func on_gamer_timer_timeout() -> void:
	game_activated = false
	
	
func restart_game() -> void:
	get_tree().reload_current_scene()
