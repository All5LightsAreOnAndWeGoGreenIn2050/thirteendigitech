extends CharacterBody2D

signal point_scored(scorer: String)

@export var initial_speed: float = 400.0
@export var max_speed: float = 800.0
@export var acceleration: float = 20.0

var Net: float = 960.0
var speed: float = initial_speed
var direction: Vector2 = Vector2.ZERO
var moving: bool = false
var x_direction: float = 0.0
var player1_bounce: int = 0
var player2_bounce: int = 0

@onready var point_area: Area2D = get_parent().get_node("Point")

func _ready() -> void:
	# Call point when ball leaves the screen
	point_area.body_exited.connect(_on_point_area_exited)
	reset()

# Puts the ball near the starting position
func reset() -> void:
	position = Vector2(Net - 290.0, 540.0)
	velocity = Vector2.ZERO
	direction = Vector2.ZERO
	moving = false
	speed = initial_speed
	player1_bounce = 0
	player2_bounce = 0
	print("ball position: ", position)

# Stops the ball just before the next serve
func stop() -> void:
	moving = false
	velocity = Vector2.ZERO

# Starts rally
func launch(serve_left: bool) -> void:
	if serve_left == true:
		x_direction = 1.0
	else:
		x_direction = -1.0
	direction = Vector2(x_direction, randf_range(-0.4, 0.4)).normalized()
	moving = true
	print("launched - direction: ", direction)
	print("serve_left: ", serve_left)

# Check who scored the point
func _on_point_area_exited(body: Node) -> void:
	if body == self:
		if position.x > Net:
			emit_signal("point_scored", "player")
		else:
			emit_signal("point_scored", "opponent")


func _physics_process(delta: float) -> void:
	if not moving:
		return
		
	# Apply some velocity
	velocity = direction * speed
	var collision = move_and_collide(velocity * delta)
	
	if collision:
		var collider = collision.get_collider()
		print("hit something: ", collider.name)
		# Reflect ball depending on direction + add spin, speed and bounce
		if collider.is_in_group("paddle"):
			direction = direction.bounce(collision.get_normal())
			add_spin(collider)
			speed = min(speed + acceleration, max_speed)
			player1_bounce = 0
			print("paddle player hit")
			collider.set("can_hit", false)
		elif collider.is_in_group("oppaddle"):
			direction = direction.bounce(collision.get_normal())
			add_spin(collider)
			speed = min(speed + acceleration, max_speed)
			player2_bounce = 0
			print("paddle opponent hit")
			collider.set("can_hit", false)
		elif collider.is_in_group("oppaddle") and collider.get("can_hit"):
			direction = direction.bounce(collision.get_normal())
			add_spin(collider)
			speed = min(speed + acceleration, max_speed)
			player2_bounce = 0
			print("paddle opponent hit")
			collider.set("can_hit", false)
		elif collider.is_in_group("pongtable"): # Calls for bounce rules
			pong_bounce()

		print("hit something: ", collision.get_collider().name)

func pong_bounce() -> void:
	# Makes sure that ball only bounces once
	var player2_side: bool = position.x > Net
	if player2_side:
		player2_bounce += 1
		if player2_bounce > 1:
			emit_signal("point_scored", "player")
			return
	else:
		player1_bounce += 1
		if player1_bounce > 1:
			emit_signal("point_scored", "opponent")
			return
	direction.y *= -1
	print("pong bounce - position: ", position, " player2_side: ", position.x > Net)

# Makes sure that no new bounce is counted after the ball crosses the net
func _process(_delta: float) -> void:
	if not moving:
		return
	if position.x > Net and player1_bounce > 0:
		player1_bounce = 0
	elif position.x < Net and player2_bounce > 0:
		player2_bounce = 0

# Add some spin
func add_spin(paddle: Node2D) -> void:
	var offset: float = (position.y - paddle.position.y) / 40.0
	direction.y += offset * 0.3
	direction = direction.normalized()
	if paddle.is_in_group("paddle"):
		player1_bounce = 0
	elif paddle.is_in_group("oppadle"):
		player2_bounce = 0
