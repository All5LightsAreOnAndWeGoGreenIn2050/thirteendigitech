extends CharacterBody2D

const GRAVITY = 1000.0

@export var move_speed: float = 200.0
@export var arrow_cooldown: float = 1.0
@export var arrow_scene: PackedScene
@export var arrow_speed: float = 900.0
@export var boundary_top_y: float = -50.0
@export var boundary_bottom_y: float = -50.0
@export var boundary_left_x: float = 800.0    
@export var boundary_right_x: float = 800.0

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
	move(delta)
	opponent_aim()
	aim_target_update(delta)
	

func move(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	
	var direction = Input.get_axis("player2_left","player2_right")
	
	velocity.x = direction * move_speed
	
	position.x = clamp(position.x, boundary_left_x, boundary_right_x)
	position.y = clamp(position.y, boundary_top_y, boundary_bottom_y)
	move_and_slide()
# Copy of ping pong clamps to do position

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
	can_fire = false
	cooldown_timer.start()
	print("opponent fired")
	print("targets array size: ", targets.size())
	
	var arrow: Node2D = arrow_scene.instantiate()
	arrow.shooter_id = "opponent"
	get_parent().add_child(arrow)
	
	var mouse_pos := get_global_mouse_position()
	var nearest_target: Node2D = null
	var nearest_dist: float = INF
	for t in targets:
		if is_instance_valid(t):
			var d: float = t.global_position.distance_to(mouse_pos)
			if d < nearest_dist:
				nearest_dist = d
				nearest_target = t
	arrow.target_node = nearest_target
	print("nearest target: ", nearest_target)
	print("target position: ", str(nearest_target.global_position) if nearest_target else "none")
	
	var arrow_position = Vector2(16,0)
	if is_instance_valid(bow_turn):
		arrow.global_position = bow_turn.global_position + \
		bow_turn.transform.x * arrow_position.x
		arrow.rotation = bow_turn.global_rotation
	else:
		arrow.global_position = Vector2(40, -10)
		
	var arrow_direction = (nearest_target.global_position - arrow.global_position).normalized()
	arrow.launch(arrow_direction, arrow_speed)
	
	
func register_targets(targets_spawning: Array) -> void:
	targets = targets_spawning
	
	
func cooldown_finished() -> void:
	can_fire = true
	
