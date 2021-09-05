extends RigidBody2D

export (float) var START_LINEAR_VELOCITY = 60
export (float) var START_ANGULAR_VELOCITY = 5
export (bool) var disabled: bool = false
var is_future: bool = false

onready var sprite = $sprite
onready var lifetime = $lifetime
onready var death_zone = $death_zone

var start_position: Vector2 = Vector2.ZERO

func _ready():
	sleeping = false
	sprite.visible = false
	set_deferred("death_zone.monitorable", false)
	
	gravity_scale = 0
	angular_velocity = 0
	rotation = 0
	linear_velocity = Vector2.ZERO
	
	if start_position == Vector2.ZERO:
		start_position = position
	else:
		position = start_position

func _reload():
	_ready()
	
func _reload_future():
	if is_future:
		is_future = false
		_ready()

func _on_trigger_zone_area_entered(area):
	if area.get_parent().name == "player" or area.get_parent().name == "player_future":
		if not disabled:
			if area.get_parent().name == "player_future":
				modulate.a = 150
				material.set_shader_param("apply", true)
				is_future = true
				lifetime.wait_time = 1
				
			angular_velocity = START_ANGULAR_VELOCITY
			linear_velocity.y = START_LINEAR_VELOCITY
			gravity_scale = 1
			
			sprite.visible = true
			set_deferred("death_zone.monitorable", true)
			
			lifetime.start()

func _on_lifetime_timeout():
	lifetime.stop()
	sleeping = true
	set_deferred("death_zone.monitorable", false)
	sprite.visible = false
	
	if is_future:
		modulate.a = 255
		material.set_shader_param("apply", false)
		_reload()
		is_future = false
		lifetime.wait_time = 4
