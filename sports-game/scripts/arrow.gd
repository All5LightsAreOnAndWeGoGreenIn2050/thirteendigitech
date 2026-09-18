extends Node2D

signal landed (arrow: Node2D)

@export var speed: float = 900.0
@export var gravity: = 900.0
@export var shooter_id: = "player"

@onready var arrow_sprite: Sprite2D = $Sprite2D

var velocity: Vector2 = Vector2.ZERO
var fly: bool = false
var target_node: Node2D = null

func launch(direction: Vector2, launch_speed: float = speed) -> void:
	velocity = direction.normalized() * launch_speed
	fly = true
		
func _process(delta: float) -> void:
	if not fly:
		return
		
	velocity.y += gravity * delta
	global_position += velocity * delta
	
	rotation = velocity.angle()
	
	if target_node and target_node.is_inside_tree():
		var arrow_distance = global_position.distance_to(target_node.global_position)
		if arrow_distance < 90:
			fly = false
			target_node.try_hit(global_position, shooter_id)
			emit_signal("landed", self)
			stick_in_target()
			return
			
	var cleanup = get_viewport_rect().size
	if global_position.y > cleanup.y + 100 or \
		global_position.x < -100 or \
		global_position.x > cleanup.x + 100:
		fly = false
		emit_signal("landed", self)
		queue_free()
		
func stick_in_target() -> void:
	set_process(false)
	var arrow_tween = create_tween()
	arrow_tween.tween_interval(1.2)
	arrow_tween.tween_property(self, "modulate:a", 0.0, 0.4)
	arrow_tween.tween_callback(queue_free)
			
	
