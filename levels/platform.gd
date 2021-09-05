extends KinematicBody2D

export (float) var DISTANCE: float = 100
export (float) var SPEED: float = 10
export (Vector2) var direction: Vector2 = Vector2.RIGHT

var stopped: bool = false
var velocity: Vector2 = Vector2.ZERO
var current_distance: float = 0
var is_future: bool = false

onready var wait = $wait_after_future

func _ready():
	if is_future:
		modulate.a = 150
		material.set_shader_param("apply", true)
		$tilemap.set_collision_layer(0)

func _physics_process(delta):
	if not stopped:
		velocity = SPEED * direction
		var _c = move_and_collide(velocity * delta)
		
		current_distance += SPEED * delta
		if current_distance >= DISTANCE:
			direction *= -1
			current_distance = 0

func _start_future():
	stopped = true
	var platform_future = load("res://levels/platform.tscn").instance()
	platform_future.direction = direction
	platform_future.current_distance = current_distance - SPEED * 0.016667
	platform_future.is_future = true
	platform_future.position = position
	get_parent().add_child(platform_future)

func _reload():
	for child in get_children():
		if child.has_method("_reload"):
			child._reload()

func _reload_future_platform():
	if is_future:
		queue_free()
	else:
		wait.start()
		
func _on_wait_after_future_timeout():
	stopped = false
	wait.stop()
