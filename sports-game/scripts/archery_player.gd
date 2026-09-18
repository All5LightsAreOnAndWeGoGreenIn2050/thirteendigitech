extends CharacterBody2D

const gravity = 1000.0

@export var move_speed: float = 200.0
@export var arrow_cooldown: float = 1.0
@export var arrow = preload("res://scenes/arrow.tscn")
@export var arrow_speed: float = 900.0

@onready var aim_guide: Node2D = %PlayerAimGuide
@onready var cooldown_timer : Timer = %Timer
@onready var bow_turn: Node2D =  %BowTurn

var can_fire: bool = true
var current_target: Node2D = null

func _ready() -> void:
	cooldown_timer.wait_time = arrow_cooldown
	cooldown_timer.one_shot = true
	cooldown_timer.timeout.connect(cooldown_finished)
	
func _process(delta: float) -> void:
	move(delta)
	aim()
	aim_target_update()
	

func move(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	
	var direction = Input.get_axis("player1_left","player2_right")
	
	velocity.x = direction * move_speed
	
	move_and_slide()
# Copy of ping pong clamps to do position

func aim() -> void:
	if not is_instance_valid(bow_turn):
		return
	var mouse_position = get_global_mouse_position()
	bow_turn.look_at(mouse_position)
	

func aim_target_update() -> void:
	aim_guide.global_position = get_global_mouse_position()
	
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and can_fire:
			fire()
			
			
func fire() -> void:
	can_fire = false
	cooldown_timer.start()
	
	var arrow: Node2D = arrow.instantiate()
	arrow.shooter_id = "player"
	get_parent().add_child(arrow)
	
	var arrow_position = Vector2(16,0)
	if is_instance_valid(bow_turn):
		arrow.global_position = bow_turn.global_position + \
		bow_turn.transform.x * arrow_position.x
		arrow.rotation = bow_turn.global_rotation
	else:
		arrow.global_position = Vector2(40, -10)
		
	var arrow_direction: = (get_global_mouse_position() - arrow.global_position).normalized()
	arrow.launch(arrow_direction, arrow_speed)
	
	
func cooldown_finished() -> void:
	can_fire = true
	
