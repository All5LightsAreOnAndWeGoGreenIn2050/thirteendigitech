extends Node2D

signal landed (arrow: Node2D)

@export var speed: float = 900.0
@export var gravity: = 10.0
@export var shooter_id: = "player"

@onready var arrow_sprite: Sprite2D = $Sprite2D

var velocity: Vector2 = Vector2.ZERO
var fly: bool = false
var target_node: Node2D = null
var landing_position: Vector2 = Vector2.ZERO

func launch_to(destination: Vector2, launch_speed: float = speed) -> void:
	# Finds the position where the arrow is supposed to land
	landing_position = destination
	var direction = (landing_position - global_position).normalized()
	velocity = direction * launch_speed
	rotation = direction.angle()
	fly = true


func _process(delta: float) -> void:
	# Stops function if arrow is not flying
	if not fly:
		return

	var distance_left = global_position.distance_to(landing_position)
	var travel_distance = velocity.length() * delta
	if distance_left > travel_distance:
		global_position += velocity.normalized() * travel_distance
		return
	
	global_position = landing_position
	fly = false
	# Check for them in target groups
	for target in get_tree().get_nodes_in_group("targets"):
		if is_instance_valid(target) and target.contains_global_position(landing_position):
			target.try_hit_target(landing_position, shooter_id)
			break
	emit_signal("landed", self)
	stick_in_target()
		
		
func stick_in_target() -> void:
	set_process(false)
	var arrow_tween = create_tween()
	arrow_tween.tween_interval(1.2)
	arrow_tween.tween_property(self, "modulate:a", 0.0, 0.4)
	arrow_tween.tween_callback(queue_free)
			
	
