extends Node2D

export (bool) var hidden: bool = false
export (bool) var disabled: bool = false
export (bool) var is_future: bool = false

onready var timer = $show_time
onready var animation = $animation_player
onready var spike = $spike
onready var death_zone = $spike/death_zone/shape
onready var audio = $audio

var activate_sound = preload("res://assets/audio/spike_up.wav")
var deactivate_sound = preload("res://assets/audio/spike_down.wav")
var already_activated: bool = false

func _ready():
	death_zone.disabled = disabled
	
	if not animation.is_playing():
		spike.visible = not hidden
	
	if is_future:
		modulate.a = 150
		material.set_shader_param("apply", true)
	else:
		modulate.a = 255
		material.set_shader_param("apply", false)
	
func _reload():
	already_activated = false
	deactivate()
	_ready()
		
func _reload_future():
	if not already_activated:
		deactivate()
		_ready()

func _on_trigger_zone_area_entered(area):
	# if it is active (can damage the player), if it is hidden and
	# if it has not been triggered before (already visible)
	if area.get_parent().name == "player_future" or area.get_parent().name == "player":
		if not disabled and hidden and not spike.visible:
			
			if area.get_parent().name == "player_future":
				modulate.a = 150
				material.set_shader_param("apply", true)
				is_future = true
				
			spike.visible = true
			animation.play("activate")
			audio.stream = activate_sound
			audio.play()
			already_activated = true

func deactivate():
	if is_future:
		is_future = false
		modulate.a = 255
		material.set_shader_param("apply", false)
	
	if hidden and spike.visible:
		animation.play("deactivate")
		audio.stream = deactivate_sound
		audio.play()

func _on_death_zone_area_entered(_area):
	timer.start()

func _on_show_time_timeout():
	timer.stop()
	deactivate()

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "deactivate":
		spike.visible = false
