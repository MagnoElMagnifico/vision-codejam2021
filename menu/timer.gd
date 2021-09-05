extends Control

export (float) var TIME: float = 120
export (float) var OLD: float = 20

onready var timer = $timer
#onready var label = $container/time_left
#onready var no_time_left = $container/no_time_left
onready var progressbar = $progressbar
onready var alarm = $alarm_effect
onready var alarm_audio = $alarm_audio
onready var clock_audio = $clock_audio

signal timer_end
signal timer_little_time

var frame_count: float = 0

func set_camera():
	for camera in get_parent().get_node("cameras").get_children():
			if camera.current:
				rect_position = Vector2(camera.position.x - 200, camera.position.y - 100)

func _ready():
#	no_time_left.visible = false
	alarm.visible = false
	
	timer.wait_time = TIME
	timer.start()
	
	var canvas = get_canvas_item()
	VisualServer.canvas_item_set_draw_index(canvas, 200)
	VisualServer.canvas_item_set_z_index(canvas, 200)

func _physics_process(delta):
	frame_count += delta
	
	if timer.time_left <= OLD and timer.time_left != 0:
		emit_signal("timer_little_time")
		alarm.visible = true
		var alpha = abs(sin(frame_count) / 3)
		alarm.color = Color(1, 0, 0, alpha)
		if alpha > 0.25 and not alarm_audio.playing:
			alarm_audio.play()
		
#	if timer != null:
#		if timer.time_left <= OLD:
#			label.visible = false
#			no_time_left.visible = true
#
#		var time: float = stepify(timer.time_left, 0.01)
#		var m = int(time / 60)
#		var d = (time - int(time)) * 100
#		var s = fmod(time - d / 100, 60)
#
#		var text: String = str(m) + ":"
#		text += str(s) if s > 9 else "0" + str(s)
#		text += "."
#		text += str(d) if d > 9 else "0" + str(d)
#
#		if label.visible:
#			label.text = text
#		else:
#			no_time_left.text = text

	progressbar.value = 100 - timer.time_left / timer.wait_time * 100

func _on_timer_timeout():
	timer.stop()
	emit_signal("timer_end")
