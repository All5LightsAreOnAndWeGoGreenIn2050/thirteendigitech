extends CharacterBody2D

@export var player_speed: float = 500.0

@onready var opponent_pong_anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var pong_game_manager: Node = %PongGameManager

var start_position: Vector2
var can_hit: bool = false

func _ready() -> void:
	start_position = position
	opponent_pong_anim.play("idle")

# Reset player each round
func reset() -> void: # Starting position
	position = start_position
	can_hit = false
	opponent_pong_anim.play("idle")

# Allows opponent to move
func _physics_process(_delta: float) -> void:
	var x_input := 0.0
	var y_input := 0.0

	if Input.is_action_pressed("player2_up"):
		y_input = -1.0
	elif Input.is_action_pressed("player2_down"):
		y_input = 1.0
	if Input.is_action_pressed("player2_left"):
		x_input = -1.0
	elif Input.is_action_pressed("player2_right"):
		x_input = 1.0

	velocity.y = y_input * player_speed
	velocity.x = x_input * player_speed
	move_and_slide()

# Detect opponent hitting input
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("player2_hit"):
		print("opponent hit")
		pong_game_manager.notify_serve("opponent")


# Allow player to hit
func enable_hit() -> void:
	can_hit = true
	
# Animation
func trigger_hit_animation() -> void:
	opponent_pong_anim.play("hit")
	await opponent_pong_anim.animation_finished
	opponent_pong_anim.play("idle")
