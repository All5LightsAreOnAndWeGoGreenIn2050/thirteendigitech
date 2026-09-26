extends CharacterBody2D

signal point_scored(scorer: String)

const CENTRE_POINT: float = 615.0

@export var initial_speed: float = 400.0
@export var max_speed: float = 800.0
@export var acceleration: float = 20.0
@export var friction: float = 25.0

var speed: float = initial_speed
var direction: Vector2 = Vector2.ZERO
var move: bool = false
var carrier: Node2D = null
var pickup_time = 0.0

@onready var player_point_area: Area2D = get_parent().get_node("GoalForPlayer")
@onready var opponent_point_area: Area2D = get_parent().get_node("GoalForOpponent")

func _ready() -> void:
	reset()

# Puts the ball near the starting position
func reset() -> void:
	position = Vector2(940.0, 540.0)
	velocity = Vector2.ZERO
	direction = Vector2.ZERO
	move = false
	speed = initial_speed
	carrier = null


func stop() -> void:
	move = false
	velocity = Vector2.ZERO
	carrier = null


func _on_goal_for_player_body_exited(_body: Node2D) -> void:
	emit_signal("point_scored", "player")


func _on_goal_for_opponent_body_exited(_body: Node2D) -> void:
	emit_signal("point_scored", "opponent")
	
	
func _physics_process(delta: float) -> void:
	if pickup_time > 0.0:
		pickup_time = maxf(pickup_time - delta, 0.0)
		
	if carrier != null:
		move = false
		velocity = Vector2.ZERO
		global_position = carrier.get_ball_anchor()
		return
	
	if not move:
		if velocity.length() > 1.0:
			velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
			move_and_collide(velocity * delta)
		return
		
	# Apply some velocity
	velocity = direction * speed
	var collision = move_and_collide(velocity * delta)
	
	if collision:
		var collider = collision.get_collider()
		print("hit something: ", collider.name)
		# Reflect ball depending on direction + add spin, speed and bounce
		if collider.is_in_group("topboundary"):
			var normal = collision.get_normal()
			direction = direction.bounce(normal).normalized()
			global_position += normal * 2.0
			speed = min(speed + acceleration, max_speed)
		elif collider.is_in_group("bottomboundary"):
			var normal = collision.get_normal()
			direction = direction.bounce(normal).normalized()
			global_position += normal * 2.0
			speed = min(speed + acceleration, max_speed)
		elif collider.is_in_group("opponentsideboundary"):
			var normal = collision.get_normal()
			direction = direction.bounce(normal).normalized()
			global_position += normal * 2.0
			speed = min(speed + acceleration, max_speed)
		elif collider.is_in_group("playersideboundary"):
			var normal = collision.get_normal()
			direction = direction.bounce(normal).normalized()
			global_position += normal * 2.0
			speed = min(speed + acceleration, max_speed)
		
		print("hit something: ", collision.get_collider().name)


func kick(dir: Vector2, kick_speed: float) -> void:
	carrier = null
	pickup_time = 0.25
	direction = dir.normalized()
	speed = clamp(kick_speed, initial_speed, max_speed)
	velocity = direction * speed
	move = true
	
	
func try_pickup(who: Node2D) -> bool:
	if carrier != null or pickup_time > 0.0:
		return false
	carrier = who
	move = false
	velocity = Vector2.ZERO
	return true
	

func ball_moves() -> void:
	move = true
