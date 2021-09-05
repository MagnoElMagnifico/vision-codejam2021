extends Node2D

export (int) var LEVEL_COUNT = 3

onready var entities = $entities
var no_future: bool = false

var level: int = 1
var timer = null

func _ready():
	for child in entities.get_children():
		if child.has_signal("end_screen"):
			child.connect("end_screen", self, "_end_screen")
			
	if no_future:
		var clock_animation = load("res://levels/clock_animation.tscn").instance()
		clock_animation.current_level = 0
		clock_animation.connect("start_clock", self, "_start_clock")
		clock_animation.connect("end_clock", self, "_end_clock")
		add_child(clock_animation)

func no_more_future():
	for respawn_point in get_node("entities").get_children():
		if respawn_point.name.begins_with("screen"):
			respawn_point.no_more_future()
	
	timer = load("res://menu/timer.tscn").instance()
	timer.connect("timer_end", self, "_timer_end")
	timer.connect("timer_little_time", self, "_timer_little_time")
	add_child(timer)
	timer.set_camera()
	
	get_node("background/controls").queue_free()
	get_node("background/controls2").queue_free()
	no_future = true

func _timer_end():
	if get_node("entities/player") != null:
		get_node("entities/player").timer_end()
	
func _timer_little_time():
	if get_node("entities/player") != null:
		get_node("entities/player").little_time()

func _end_screen():
	level += 1
	
	if level > LEVEL_COUNT:
		var transition = load("res://menu/transition.tscn").instance()
		transition.connect("transition_end", self, "_on_transition_end")
		add_child(transition)
		transition._out()
	
	if level <= LEVEL_COUNT:
		get_node("cameras/screen" + str(level)).current = true
	get_node("cameras/screen" + str(level - 1)).current = false
	
	if timer != null:
		timer.set_camera()
	
	if no_future:
		var clock_animation = load("res://levels/clock_animation.tscn").instance()
		clock_animation.current_level = level - 1
		clock_animation.connect("start_clock", self, "_start_clock")
		clock_animation.connect("end_clock", self, "_end_clock")
		add_child(clock_animation)

func _start_clock():
	if get_node("entities/player") != null:
		get_node("entities/player").can_move = false
	
func _end_clock():
	if get_node("entities/player") != null:
		get_node("entities/player").can_move = true

func _on_transition_end():
	var final_level = load("res://levels/final_level.tscn").instance()
	if no_future:
		final_level.activate_end()
	get_parent().add_child(final_level)
	queue_free()

func stop_timer():
	timer.timer.stop()
	timer.clock_audio.stop()
	timer.alarm_audio.stop()
