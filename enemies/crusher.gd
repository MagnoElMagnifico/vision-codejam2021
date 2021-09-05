extends Node2D

export (Vector2) var CLOSING_SPEED: Vector2 = Vector2(0, 50)
export (float) var KILL_DISTANCE: float = 50
export (bool) var is_active: bool = true

onready var floor_part = $floor_part
onready var top_part = $top_part
onready var death_zone = $floor_part/death_zone
onready var audio = $audio

var already_activated: bool = false
var is_future: bool = false
var is_closing: bool = false
var start_top_position: Vector2 = Vector2.ZERO
var start_floor_position: Vector2 = Vector2.ZERO

func _ready():
	floor_part.visible = false
	top_part.visible = false
	death_zone.monitorable = false
	already_activated = false
	floor_part.set_collision_mask_bit(2, false)
	top_part.set_collision_mask_bit(2, false)
	floor_part.set_collision_mask_bit(1, false)
	top_part.set_collision_mask_bit(1, false)
	
	modulate.a = 255
	material.set_shader_param("apply", false)
	
	is_closing = false
	if start_top_position == Vector2.ZERO:
		start_top_position = top_part.position
	else:
		top_part.position = start_top_position
		
	if start_floor_position == Vector2.ZERO:
		start_floor_position = floor_part.position
	else:
		floor_part.position = start_floor_position
	
func _reload():
	_ready()
	
func _reload_future():
	if is_future:
		is_future = false
		_ready()

func _on_trigger_zone_area_entered(area):
	if area.get_parent().name == "player" or area.get_parent().name == "player_future":
		if is_active and not is_closing and not already_activated:
			if area.get_parent().name == "player_future":
				modulate.a = 150
				material.set_shader_param("apply", true)
				is_future = true
				
			floor_part.visible = true
			top_part.visible = true
			is_closing = true
			already_activated = true
			audio.play()

func _physics_process(delta):
	if is_closing:
		var top_collision = top_part.move_and_collide(CLOSING_SPEED * delta)
		var _a = floor_part.move_and_collide(CLOSING_SPEED * -delta)
		
		if top_part.position.distance_to(floor_part.position) <= KILL_DISTANCE:
			call_deferred("set_death_zone_true")
		
		if top_collision != null and top_collision.collider.name == "floor_part":
			is_closing = false
			floor_part.set_collision_mask_bit(2, true)
			top_part.set_collision_mask_bit(2, true)
			floor_part.set_collision_mask_bit(1, true)
			top_part.set_collision_mask_bit(1, true)
			audio.stop()
			
func set_death_zone_true():
	death_zone.monitorable = true
