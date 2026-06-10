extends CharacterBody2D

@export var player_speed: float = 500.0
@export var boundary_top_y: float = -50.0
@export var boundary_bottom_y: float = 750.0
@export var boundary_left_x: float = -260.0    
@export var boundary_right_x: float = 440.0

@onready var player_pong_anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var pong_game_manager: Node = %PongGameManager

var start_position: Vector2
var can_hit: bool = false

func _ready() -> void: # Paddle starting position
	start_position = position
	player_pong_anim.play("idle")

# Position of player of each new round
func reset() -> void:
	position = start_position
	can_hit = false
	player_pong_anim.play("idle")

# Allows the player to move
func _physics_process(_delta: float) -> void:
	var x_input := 0.0
	var y_input := 0.0

	if Input.is_action_pressed("player1_up"):
		y_input = -1.0
	elif Input.is_action_pressed("player1_down"):
		y_input = 1.0

	velocity.y = y_input * player_speed
	velocity.x = x_input * player_speed
	# Restrict player to certain boundaries
	position.x = clamp(position.x, boundary_left_x, boundary_right_x)
	position.y = clamp(position.y, boundary_top_y, boundary_bottom_y)
	move_and_slide()

# Detect player hitting input
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("player1_hit"):
		trigger_hit_animation()
		print("player hit")
		pong_game_manager.notify_serve("player")
		
# Allow player to hit
func enable_hit() -> void:
	can_hit = true

# Animation
func trigger_hit_animation() -> void:
	player_pong_anim.play("hit")
	await player_pong_anim.animation_finished
	player_pong_anim.play("idle")
