extends Node2D

export (float) var RANDOM_FORCE: float = 500

onready var base = $Base_physics
onready var legs = $Legs_physics
onready var back_arm = $Back_arm_physics
onready var body = $Body_physics
onready var top_arm = $Top_arm_physics
onready var head = $Head_physics

onready var audio = $audio
onready var lifetime = $lifetime
onready var particles = $particles
var is_future: bool = false
var timer_end: bool = false

var death = [
	preload("res://assets/audio/boom1.wav"),
	preload("res://assets/audio/boom2.wav"),
	preload("res://assets/audio/boom3.wav")
]

func _ready():
	if is_future:
		modulate.a = 150
		material = load("res://player/player_future_shader.tres")
		material.set_shader_param("apply", true)
		lifetime.wait_time = 1
		call_deferred("set_particles")
	
	particles.emitting = true
	
	if not timer_end:
		base    .apply_central_impulse(calculate_force())
		legs    .apply_central_impulse(calculate_force())
		back_arm.apply_central_impulse(calculate_force())
		body    .apply_central_impulse(calculate_force())
		top_arm .apply_central_impulse(calculate_force())
		head    .apply_central_impulse(calculate_force())
		lifetime.start()
		audio.stream = death[randi() % death.size()]
		audio.play()
	
func set_particles():
	particles.hue_variation = 0.5

func calculate_force():
	return Vector2(randf() * RANDOM_FORCE - RANDOM_FORCE/2, randf() * RANDOM_FORCE - RANDOM_FORCE/2)

func set_future():
	is_future = true
	
func set_waiting():
	material = load("res://player/player_waiting.tres")
	material.set_shader_param("saturation", 0.0)
	
func _on_lifetime_timeout():
	queue_free()
