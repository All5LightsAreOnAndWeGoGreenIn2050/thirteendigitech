extends Node2D

# Emitted when an arrow hits or misses the target
signal hit(points: int, shooter: String)

const outer_radius: float = 16.0
const rings_points := [
	{ "radius": 16.0, "points": 10 }, # White
	{ "radius": 12.5, "points": 20 }, # Black
	{ "radius": 9.5, "points": 50 }, # Blue
	{ "radius": 6.5, "points": 60 }, # Red
	{ "radius": 4.0, "points": 75 }, # Yellow
	{ "radius": 2.0, "points": 100 }, # Gold
]

@onready var target_sprite: Sprite2D = $Sprite2D

# Detects how much points the player should get
func try_hit_target(arrow_global_position: Vector2, shooter: String) -> bool:
	var local_position = to_local(arrow_global_position)
	var distance := local_position.length()

	if distance > outer_radius:
		emit_signal("hit", 0, shooter)
		return false
	   
	var points: int = 10
	for i in range(rings_points.size() -1, -1, -1):
		if distance <= rings_points[i]["radius"]:
			points = rings_points[i]["points"]
			break		
			
	emit_signal("hit", points, shooter)
	play_hit_signal(points)
	return true
		
# Hit signal
func play_hit_signal(points: int) -> void:
	var tween = create_tween()
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
	label.position = Vector2(-18, - (outer_radius +12))
	add_child(label)
	var tween = create_tween()
	tween.tween_property(label, "position", label.position + Vector2(0, -45), 0.9)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 0.9)
	tween.tween_callback(label.queue_free)
