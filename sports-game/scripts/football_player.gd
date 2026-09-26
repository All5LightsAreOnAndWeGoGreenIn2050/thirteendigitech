extends CharacterBody2D

@export var action_prefix: String = "player1"
@export var ball_path: NodePath
@export var player_speed: float = 500.0
@export var dribble_speed: float = 400.0
@export var max_shot_speed: float = 800.0
@export var min_shot_speed: float = 300.0
@export var shot_charge_time: float = 1.0
@export var tackle_range: float = 44.0
@export var tackle_time: float = 0.8
@export var lunge_time: float = 0.2
@export var lunge_speed: float = 400
@export var stun_time: float = 0.5
@export var ball_offset: float = 26.0
@export var pickup_radius: float = 95.0

@onready var ball = get_node(ball_path)
@onready var football_player_anim: AnimatedSprite2D = $AnimatedSprite2D

var start_position: Vector2
var charging: bool = false
var charge: float = 0.0
var frozen: bool = false
var _stun_timer: float = 0
var _lunge_timer: float = 0
var _tackle_timer: float = 0
var _lunge_direction: Vector2 = Vector2.ZERO

func _ready() -> void:
	start_position = position
	football_player_anim.play("idle")
	if ball == null:
		push_error("ball_path is not set on %s — assign it in the Inspector" % name)
	print(name, " ball reference: ", ball, " | instance id: ", ball.get_instance_id() if ball else "none")


func _physics_process(delta: float) -> void:
	_stun_timer = maxf(_stun_timer - delta, 0.0)
	_lunge_timer = maxf(_lunge_timer - delta, 0.0)
	_tackle_timer = maxf(_tackle_timer - delta, 0.0)
	
	if frozen:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	var x_input = 0.0
	var y_input = 0.0
	if Input.is_action_pressed("player1_up"):
		y_input = -1.0
	if Input.is_action_pressed("player1_down"):
		y_input = 1.0
	if Input.is_action_pressed("player1_left"):
		x_input = -1.0
	if Input.is_action_pressed("player1_right"):
		x_input = 1.0
	var input = Vector2(x_input, y_input).normalized()
	
	var speed = player_speed
	if has_ball():
		speed = dribble_speed
	
	var target = input * speed
	if _stun_timer > 0.0:
		target = Vector2.ZERO
	elif _lunge_timer > 0.0:
		target = _lunge_direction * lunge_speed
 
	velocity = target
	move_and_slide()
 
	handle_ball(delta, input)
	update_animation(input)


func has_ball() -> bool:
	return ball != null and ball.carrier == self
	
	
func get_ball_anchor() -> Vector2:
	return global_position


func handle_ball(delta: float, input: Vector2) -> void:
	if ball.carrier == null and _stun_timer <= 0.0:
		if global_position.distance_to(ball.global_position) <= pickup_radius:
			ball.try_pickup(self)
 
	if _lunge_timer > 0.0:
		try_steal()
 
	if has_ball():
		handle_shooting(delta, input)
	else:
		cancel_charge()
		if Input.is_action_just_pressed("player1_tackle") and _tackle_timer <= 0.0 and _stun_timer <= 0.0:
			_tackle_timer = tackle_time
			_lunge_timer = lunge_time
			_lunge_direction = input


func try_steal() -> void:
	var holder = ball.carrier
	if holder == null or holder == self:
		return
	if global_position.distance_to(ball.global_position) <= tackle_range:
		if holder.has_method("get_tackled"):
			holder.get_tackled()
		ball.carrier = self
		_lunge_timer = 0.0
 
 
func get_tackled() -> void:
	_stun_timer = stun_time
	cancel_charge()
 
 
func handle_shooting(delta: float, input: Vector2) -> void:
	if Input.is_action_just_pressed(_a("hit")):
		charging = true
		charge = 0.0
	if charging:
		charge = minf(charge + delta / shot_charge_time, 1.0)
		if Input.is_action_just_released(_a("hit")):
			shoot(input)
 
 
func shoot(input: Vector2) -> void:
	var dir = input if input != Vector2.ZERO else Vector2.RIGHT
	ball.kick(dir, lerpf(min_shot_speed, max_shot_speed, charge))
	cancel_charge()
 
 
func cancel_charge() -> void:
	charging = false
	charge = 0.0
 
 
func reset_to(pos: Vector2) -> void:
	global_position = pos
	velocity = Vector2.ZERO
	_stun_timer = 0.0
	_tackle_timer = 0.0
	_lunge_timer = 0.0
	cancel_charge()
 
 
func update_animation(input: Vector2) -> void:
	if input != Vector2.ZERO and _stun_timer <= 0.0:
		if football_player_anim.animation != "walk":
			football_player_anim.play("walk")
	else:
		if football_player_anim.animation != "idle":
			football_player_anim.play("idle")
 
 
func _a(action: String) -> String:
	return "%s_%s" % [action_prefix, action]
		
