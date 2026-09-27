extends CharacterBody2D

signal point_scored(scorer: String)

const CENTRE_POINT: float = 615.0

@export var initial_speed: float = 400.0
@export var max_speed: float = 800.0
@export var acceleration: float = 20.0
@export var friction: float = 25.0
@export var gravity: float = 1500.0
@export var sprite: Node2D

var speed: float = initial_speed
var direction: Vector2 = Vector2.ZERO
var move: bool = false
var carrier: Node2D = null
var pickup_time = 0.0
var height: float = 0.0
var height_velocity: float = 0.0

@onready var player_point_area: Area2D = get_parent().get_node("PlayerGoal")
@onready var opponent_point_area: Area2D = get_parent().get_node("OpponentGoal")

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
	height = 0.0
	height_velocity = 0.0
	update_sprite_height()


func in_air() -> bool:
	return height > 0.0


func stop() -> void:
	move = false
	velocity = Vector2.ZERO
	carrier = null
	
	
func _physics_process(delta: float) -> void:
	if pickup_time > 0.0:
		pickup_time = maxf(pickup_time - delta, 0.0)
		
	update_height(delta)
		
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
		if collider.is_in_group("walls"):
			var normal = collision.get_normal()
			direction = direction.bounce(normal).normalized()
			global_position += normal * 2.0
			speed = min(speed + acceleration, max_speed)
		
		print("hit something: ", collision.get_collider().name)


func update_height(delta: float) -> void:
	if height <= 0.0 and height_velocity <= 0.0:
		return
		
	height += height_velocity * delta
	height_velocity -= gravity * delta
	
	if height <= 0.0:
		height = 0.0
		height_velocity = 0.0
	
	update_sprite_height()


func update_sprite_height() -> void:
	if sprite:
		sprite.position.y = -height


func kick(dir: Vector2, kick_speed: float, loft_speed: float = 0.0) -> void:
	carrier = null
	pickup_time = 0.25
	direction = dir.normalized()
	speed = clamp(kick_speed, initial_speed, max_speed)
	velocity = direction * speed
	move = true
	height_velocity = loft_speed
	
	
func try_pickup(who: Node2D) -> bool:
	if carrier != null or pickup_time > 0.0:
		return false
	carrier = who
	move = false
	velocity = Vector2.ZERO
	return true
	

func ball_moves() -> void:
	move = true


func _on_player_goal_body_entered(_body: Node2D) -> void:
	emit_signal("point_scored", "player")


func _on_opponent_goal_body_entered(_body: Node2D) -> void:
	emit_signal("point_scored", "opponent")
