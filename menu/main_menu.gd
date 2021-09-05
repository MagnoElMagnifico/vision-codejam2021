extends Control

onready var audio = $audio

var tran = preload("res://menu/transition.tscn")
var level = preload("res://levels/factory_level.tscn")

func _on_start_pressed():
	get_parent().add_child(level.instance())
	
	var transition = tran.instance()
	transition.connect("transition_end", self, "_transition_end")
	add_child(transition)
	
	transition._in()
	audio.play()

func _transition_end():
	queue_free()

func _on_exit_pressed():
	audio.play()
	get_tree().quit()
