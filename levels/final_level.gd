extends Node2D

var factory_level = preload("res://levels/factory_level.tscn")

onready var transition = $transition
onready var future_audio = $future_audio
var activated: bool = false
var count: int = 0
var end: bool = false

func _ready():
	transition._in()
	
	var light_canvas = $light_effect.get_canvas_item()
	VisualServer.canvas_item_set_draw_index(light_canvas, 150)
	VisualServer.canvas_item_set_z_index(light_canvas, 150)

func activate_end():
	end = true

func _physics_process(_delta):
	if not end:
		if activated and is_instance_valid(future_audio):
			future_audio.volume_db -= 1
		else: 
			if count % 10 == 0:
				var apply: bool = randf() < 0.7
				var amount: float = randf() * 20
				
				material.set_shader_param("apply", apply)
				material.set_shader_param("amount", amount)
			count += 1
			
			if count > 1000:
				count = 0
	else:
		future_audio.stop()

func _on_trigger_zone_area_entered(area):
	if area.owner.name == "player":
		transition._out()
		activated = true

func _on_transition_transition_end():
	if activated:
		if not end:
			var level = factory_level.instance()
			level.no_more_future()
			get_parent().add_child(level)
			queue_free()
		else:
			var game_over = load("res://menu/game_over.tscn").instance()
			game_over.set_victory()
			add_child(game_over)
