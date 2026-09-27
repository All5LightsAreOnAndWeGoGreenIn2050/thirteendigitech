extends Node2D

# Emitted when an arrow hits or misses the target
signal hit(points: int, shooter: String)

const OUTER_RADIUS: float = 88.0
const RING_SCORES = {
	"gold": 100,
	"yellow": 75,
	"red": 60,
	"blue": 50,
	"black": 20,
	"white": 10,
}

@export var min_respawn_time: float = 1.0
@export var max_respawn_time: float = 3.0

@onready var target_sprite: Sprite2D = $Sprite2D

var is_hit: bool = false

func contains_global_position(global_point: Vector2) -> bool:
	var outer_shape = get_node("White/CollisionShape2D") as CollisionShape2D
	var circle = outer_shape.shape as CircleShape2D
	return outer_shape.to_local(global_point).length() <= circle.radius

# Detects how much points the player should get
func try_hit_target(arrow_global_position: Vector2, shooter: String) -> bool:
	if is_hit:
		return false
	# Check each ring for highest value to lowest value in order to assign points
	var points = 0
	for ring in ["gold", "yellow", "red", "blue", "black", "white"]:
		var area = get_node(ring.capitalize())
		var collision_shape = area.get_node("CollisionShape2D") as CollisionShape2D
		var local_position = collision_shape.to_local(arrow_global_position)
		if local_position.length() <= collision_shape.shape.radius:
			points = RING_SCORES[ring]
			break
	# emits the signal with the amount of points the player has scored
	emit_signal("hit", points, shooter)
	play_hit_signal(points)
	if points > 0:
		hide_target()
	return points > 0
	
	
func hide_target() -> void:
	is_hit = true
	target_sprite.visible = false
	
	var wait_time: float = randf_range(min_respawn_time, max_respawn_time)
	await get_tree().create_timer(wait_time).timeout
	respawn()
	
	
func respawn() -> void:
	# Makes sure targets respawn with the right scale
	target_sprite.scale = Vector2(5.5, 5.718)
	var vp_size = get_tree().root.get_visible_rect().size
	var margin = Vector2 (150, 120)
	position = Vector2(
		randf_range(margin.x, vp_size.x - margin.x),
		randf_range(margin.y, vp_size.y - 200.0)
	)
	target_sprite.visible = true
	is_hit = false
		
		
func play_hit_signal(points: int) -> void:
	var tween = create_tween()
	target_sprite.scale = Vector2(1.0, 1.0)
	tween.tween_property(target_sprite, "scale", Vector2(1.18, 1.18), 0.07)
	tween.tween_property(target_sprite, "scale", Vector2(1.0, 1.0), 0.13)
	popup_score(points)
	
# Animation effects
func popup_score(points: int) -> void:
	if points == 0:
		return
	var label = Label.new()
	label.text = "+%d" % points
	label.add_theme_font_size_override("font_size", 22)
	label.position = Vector2(-18, - (OUTER_RADIUS + 6))
	add_child(label)
	var tween = create_tween()
	tween.tween_property(label, "position", label.position + Vector2(0, -45), 0.9)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 0.9)
	tween.tween_callback(label.queue_free)
	
