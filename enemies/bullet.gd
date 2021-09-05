extends KinematicBody2D

export (Vector2) var VELOCITY: Vector2 = Vector2.ZERO
export (float) var LIFETIME: float = 3

onready var particles = $particles
onready var death_zone = $death_zone
onready var lifetime = $lifetime
onready var audio = $audio

var velocity: Vector2 = Vector2.ZERO
var start_position: Vector2 = Vector2.ZERO
var is_future: bool = false
var activated: bool = false

func _ready():
	particles.direction = VELOCITY.normalized()
	lifetime.wait_time = LIFETIME
	death_zone.monitorable = false
	if start_position == Vector2.ZERO:
		start_position = position
	else:
		position = start_position

func _reload():
	deactivate()

func _reload_future():
	deactivate()

func deactivate():
	if is_future:
		modulate.a = 255
		material.set_shader_param("apply", false)
		is_future = false
	
	position = start_position
	velocity = Vector2.ZERO
	particles.emitting = false
	activated = false
	death_zone.monitorable = false

func _physics_process(_delta):
	velocity = move_and_slide(velocity)

func _on_trigger_zone_area_entered(area):
	if not activated:
		if area.get_parent().name == "player" or area.get_parent().name == "player_future":
			if area.get_parent().name == "player_future":
				modulate.a = 150
				material.set_shader_param("apply", false)
				is_future = true
			
			velocity = VELOCITY
			particles.emitting = true
			lifetime.start()
			activated = true
			audio.play()
			call_deferred("activate_death_zone")

func activate_death_zone():
	death_zone.monitorable = true

func _on_lifetime_timeout():
	lifetime.stop()
	deactivate()
