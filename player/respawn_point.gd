extends Node2D

export (bool) var is_active: bool = false
var is_connected: bool = false
var no_future: bool = false

onready var wait_time = $wait_time
onready var future_wait_time = $future_wait_time
onready var start_wait_time = $start_wait_time
onready var audio = $audio

#### SETUP ####
func _ready():
	if is_active:
		if no_future:
			start_wait_time.wait_time += 2.5
		start_wait_time.start()
		
func _on_start_wait_time_timeout():
	call_deferred("load_player")
	start_wait_time.stop()
		
func _on_trigger_zone_area_entered(area):
	if not is_active and area.get_parent().name == "player":
		for respawn_point in get_parent().get_children():
			if respawn_point.has_method("_deactivate_respawn_point"):
				respawn_point._deactivate_respawn_point()
		is_active = true
		
		if not is_connected:
			var player = get_parent().get_node("player")
			player.connect("die_explote", self, "_on_player_die_explote")
			player.connect("future_dead", self, "_on_player_future_dead")
			player.connect("end_future", self, "_on_player_end_future")
			player.connect("start_future", self, "_on_player_start_future")
			is_connected = true
	
func _deactivate_respawn_point():
	is_active = false

func load_player():
	var player = load("res://player/player.tscn").instance()
	
	player.connect("die_explote", self, "_on_player_die_explote")
	player.connect("future_dead", self, "_on_player_future_dead")
	player.connect("end_future", self, "_on_player_end_future")
	player.connect("start_future", self, "_on_player_start_future")
	player.position = position
	
	if no_future:
		player.no_future = true
	
	is_connected = true
	
	get_parent().add_child(player)
	audio.play()
	
	reload_enemies()
	
func reload_enemies():
	for child in get_children():
		if child.has_method("_reload"):
			child._reload()

#### DEATH ####
func _on_player_die_explote():
	if is_active:
		if not no_future:
			reload_future_platforms()
			reload_future_enemies()
		wait_time.start()
	
func _on_wait_time_timeout():
	wait_time.stop()
	if not no_future:
		call_deferred("load_player")
	else:
		owner.stop_timer()
		var game_over = load("res://menu/game_over.tscn").instance()
		game_over.set_death()
		owner.add_child(game_over)
		
#### FUTURE ####
func _on_player_future_dead():
	if is_active:
		reload_future_platforms()
		future_wait_time.start()
	
func _on_future_wait_time_timeout():
	reload_future_enemies()
	future_wait_time.stop()
	
func _on_player_end_future():
	if is_active:
		reload_future_platforms()
		reload_future_enemies()
	
func reload_future_platforms():
	for child in get_children():
		if child.has_method("_reload_future_platform"):
			child._reload_future_platform()

func _on_player_start_future():
	for child in get_children():
		if child.has_method("_start_future"):
			child._start_future()
	
func reload_future_enemies():
	for child in get_children():
		if child.has_method("_reload_future"):
			child._reload_future()
			
#### NO FUTURE ####
func no_more_future():
	no_future = true
