extends CharacterBody2D


@export var move_speed: float = 200.0
@export var arrow_cooldown: float = 1.0
@export var arrow_scene: PackedScene
@export var arrow_speed: float = 900.0
@export var boundary_top_y: float = 700
@export var boundary_bottom_y: float = 700
@export var boundary_left_x: float = -200.0
@export var boundary_right_x: float = -200.0

@onready var aim_guide: Node2D = %"Opponent Aim Target"
@onready var cooldown_timer : Timer = %Timer
@onready var bow_turn: Node2D =  $OpponentBowTurn

var can_fire: bool = true
var current_target: Node2D = null
var targets: Array = []

func _ready() -> void:
	cooldown_timer.wait_time = arrow_cooldown
	cooldown_timer.one_shot = true
	cooldown_timer.timeout.connect(cooldown_finished)
	
	
func _process(delta: float) -> void:
	opponent_aim()
	aim_target_update(delta)
	

func opponent_aim() -> void:
	if not is_instance_valid(bow_turn):
		return
	bow_turn.look_at(aim_guide.global_position)
	

func aim_target_update(delta: float) -> void:
	var aim_direction = Vector2.ZERO
	
	if Input.is_action_pressed("player2_left"):
		aim_direction.x -= 1.0
	if Input.is_action_pressed("player2_right"):
		aim_direction.x += 1.0
	if Input.is_action_pressed("player2_down"):
		aim_direction.y += 1.0
	if Input.is_action_pressed("player2_up"):
		aim_direction.y -= 1.0
		
	if aim_direction.length() > 0:
		aim_direction = aim_direction.normalized()
		
	aim_guide.global_position += aim_direction * move_speed * delta
	
	
func _input(_event: InputEvent) -> void:
	if Input.is_action_pressed("player2_hit"):
		fire()
			
			
func fire() -> void:
	# Checks whether or not the player can fire and prevent them from firing immediately
	if not can_fire:
		return
	can_fire = false
	cooldown_timer.start()
	# Launches the arrow based on the bow position to the aim guide position
	var arrow: Node2D = arrow_scene.instantiate()
	arrow.shooter_id = "opponent"
	var bow_sprite = bow_turn.get_node("Sprite2D") as Sprite2D
	var aim_sprite = aim_guide.get_node("Sprite2D") as Sprite2D
	var launch_origin: Vector2 = bow_sprite.global_position
	var aim_point: Vector2 = aim_sprite.global_position
	get_parent().add_child(arrow)
	arrow.global_position = launch_origin
	if aim_point.is_equal_approx(launch_origin):
		arrow.queue_free()
		return
	arrow.launch_to(aim_point, arrow_speed)
	
	
func register_targets(targets_spawning: Array) -> void:
	targets = targets_spawning
	
	
func cooldown_finished() -> void:
	can_fire = true
	
