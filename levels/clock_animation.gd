extends Node2D

export (float) var TIME: float = 3
export (float) var OFFSET: float = 1
export (int) var TOTAL_LEVELS: int = 5
export (int) var current_level: int = 0

onready var hand = $hand_clock
onready var lifetime = $lifetime
var speed: float = 0
var level_distance: float = 0
var current_distance: float = 0

signal start_clock
signal end_clock

func _ready():
	for camera in get_parent().get_node("cameras").get_children():
		if camera.current:
			position = Vector2(camera.position.x - 200, camera.position.y - 100)
			
	var canvas = get_canvas_item()
	VisualServer.canvas_item_set_draw_index(canvas, 199)
	VisualServer.canvas_item_set_z_index(canvas, 199)
	
	level_distance = 360.0 / TOTAL_LEVELS
	speed = level_distance / (TIME - OFFSET)
	
	hand.rotation_degrees = current_level * level_distance
	
	lifetime.wait_time = TIME
	lifetime.start()
	
	emit_signal("start_clock")

func _physics_process(delta):
	if current_distance < level_distance:
		hand.rotation_degrees += speed * delta
		current_distance += speed * delta
	

func _on_lifetime_timeout():
	lifetime.stop()
	emit_signal("end_clock")
	queue_free()
