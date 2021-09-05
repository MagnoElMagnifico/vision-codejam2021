extends KinematicBody2D

export (float) var GRAVITY: float = 300
export (float) var MAX_GRAVITY: float = 300
export (float) var MAX_SPEED: float = 100
export (float) var LIFETIME: float = 5

onready var parts = $parts
onready var lifetime = $lifetime
signal future_dead
signal end_future

var velocity: Vector2 = Vector2.ZERO
var direction: int = 0
var platform

func set_direction(new_direction: int):
	direction = new_direction

func _ready():
	modulate.a = 150
	material.set_shader_param("apply", true)
	parts.scale = Vector2(direction, 1)
	velocity = Vector2(MAX_SPEED * direction, 0)
	platform = null
	lifetime.wait_time = LIFETIME
	lifetime.start()

func _physics_process(delta):
	if platform == null:
		if not is_on_floor():
			velocity.y = move_toward(velocity.y, MAX_GRAVITY, GRAVITY * delta)
	else:
		velocity = platform.velocity
	velocity = move_and_slide(velocity, Vector2.UP)

func _on_hitbox_area_entered(_area):
	call_deferred("die_explote")

func die_explote():
	var physics_player = load("res://player/player_explosion.tscn").instance()
	physics_player.position = position
	physics_player.set_future()
	get_parent().add_child(physics_player)
	emit_signal("future_dead")
	queue_free()

func _on_lifetime_timeout():
	emit_signal("end_future")
	queue_free()

func _on_trigger_zone_area_entered(area):
	if area.owner.name.begins_with("@platform") and area.owner.is_future:
		platform = area.owner
		lifetime.wait_time += 3
		set_collision_layer(0)
		set_collision_mask(0)
	elif area.owner.name.begins_with("jump"):
		velocity += area.owner.BOOST
