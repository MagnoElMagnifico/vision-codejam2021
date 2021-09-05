extends Control

onready var audio = $audio
onready var message = $menu/buttons/message
var factory_level = preload("res://levels/factory_level.tscn")
var is_loss: bool 

func _ready():
	if get_parent().name != "final_level":
		for camera in get_parent().get_node("cameras").get_children():
			if camera.current:
				rect_position = Vector2(camera.position.x - 200, camera.position.y - 100)
	else:
		rect_position = Vector2.ZERO
		
	var player = get_canvas_item()
	VisualServer.canvas_item_set_draw_index(player, 200)
	VisualServer.canvas_item_set_z_index(player, 200)
	
	if is_loss:
		message.text = "YOU DIED"
		audio.stream = load("res://assets/audio/game_over.wav")
	else:
		message.text = "CONGRATULATIONS!"
		audio.stream = load("res://assets/audio/victory.wav")
	audio.play()

func set_death():
	is_loss = true
	
func set_victory():
	is_loss = false
	$menu/buttons/retry.queue_free()

func _on_retry_pressed():
	var level = factory_level.instance()
	level.no_more_future()
	get_parent().get_parent().add_child(level)
	audio.stream = load("res://assets/audio/button.wav")
	audio.play()
	get_parent().queue_free()

func _on_exit_pressed():
	var main_menu = load("res://menu/main_menu.tscn").instance()
	get_parent().get_parent().add_child(main_menu)
	audio.stream = load("res://assets/audio/button.wav")
	audio.play()
	get_parent().queue_free()
	
