extends Control

onready var audio = $audio
onready var audio_level = $menu/pause_menu/audio_level

func _ready():
	if get_parent().name == "factory_level":
		audio_level.value = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))
		
		for camera in get_parent().get_node("cameras").get_children():
			if camera.current:
				rect_position = Vector2(camera.position.x - 200, camera.position.y - 100)

		get_tree().paused = true
		var player = get_canvas_item()
		VisualServer.canvas_item_set_draw_index(player, 200)
		VisualServer.canvas_item_set_z_index(player, 200)
		
		audio.play()
		
	else:
		queue_free()

func _input(_event):
	if Input.is_action_just_pressed("pause_menu"):
		close()

func _on_kill_pressed():
	get_tree().paused = false
	get_parent().get_node("entities/player").die_explote()
	queue_free()

func _on_resume_pressed():
	close()

func _on_audio_level_value_changed(value):
	if value < -24:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), -100)
	else:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), value)
	audio.play()
	
func close():
	get_tree().paused = false
	queue_free()
	
func _on_exit_pressed():
	get_tree().paused = false
	var main_menu = load("res://menu/main_menu.tscn").instance()
	get_parent().get_parent().add_child(main_menu)
	get_parent().queue_free()
