extends KinematicBody2D

export (float) var GRAVITY: float = 300
export (float) var MAX_GRAVITY: float = 300
export (float) var JUMP: float = 130
export (float) var FALL: float = 100
export (float) var MAX_SPEED: float = 150
export (float) var ACCELERATION: float = 350
export (float) var FRICTION: float = 300
export (float) var COOLDOWN: float = 10
export (float) var COYOTE_TIME: float = 0.25
export (float) var OLD: float = 0.1

onready var animation = $animation_player
onready var parts = $parts
onready var audio = $audio
onready var cooldown = $cooldown
onready var wait_after_future = $wait_after_future
onready var clock = $clock

var jump_sounds = [
	preload("res://assets/audio/jump1.wav"),
	preload("res://assets/audio/jump2.wav"),
#	preload("res://assets/audio/jump3.wav"),
	preload("res://assets/audio/jump4.wav"),
	preload("res://assets/audio/jump5.wav")
]
var jumpad_sound = preload("res://assets/audio/jumpad.wav")
var no_future_sound = preload("res://assets/audio/no_future.wav")

signal die_explote
signal future_dead
signal end_future
signal start_future
enum State {NORMAL, IN_FUTURE, WAITING}

var coyote_time: float = 0
var velocity: Vector2 = Vector2.ZERO
var state = State.NORMAL
var platform
var no_future: bool = false
var can_move: bool = true

func _ready():
	cooldown.wait_time = COOLDOWN
	parts.material.set_shader_param("saturation", 1)
	clock.visible = false
	clock.stop = true
	
	# Always drawn on top
	var player = get_canvas_item()
	VisualServer.canvas_item_set_draw_index(player, 50)
	VisualServer.canvas_item_set_z_index(player, 50)

func jump(direction: Vector2):
	direction.y = - Input.get_action_strength("player_jump")
	velocity.y = -JUMP
	
	if not audio.playing:
		audio.stream = jump_sounds[randi() % jump_sounds.size()]
		audio.play()

func _physics_process(delta):
	if state != State.IN_FUTURE:
		# Calculate the direction
		var direction: Vector2 = Vector2.ZERO
		
		if can_move:
			direction.x = Input.get_action_strength("player_right") - Input.get_action_strength("player_left")
			
			if is_on_floor():
				coyote_time = 0
				if Input.is_action_pressed("player_jump"):
					jump(direction)
			elif Input.is_action_pressed("player_jump") and coyote_time <= COYOTE_TIME:
				coyote_time += delta
				jump(direction)
			else:
				coyote_time += delta
				direction.y = 1
		
			direction = direction.normalized()

		# Apply the direction on the velocity
		if direction.x == 0:
			if platform == null:
				velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
			else:
				velocity = velocity.move_toward(platform.velocity, FRICTION * delta)
		else:
			if direction.x > 0:
				parts.scale = Vector2(1, 1)
			else:
				parts.scale = Vector2(-1, 1)
			velocity.x = move_toward(velocity.x, direction.x * MAX_SPEED, ACCELERATION * delta)
		velocity.y = move_toward(velocity.y, direction.y * MAX_GRAVITY, GRAVITY * delta)
		
		velocity = move_and_slide(velocity, Vector2.UP)
		
		# Animation
		if velocity.y > FALL:
			animation.play("fall")
		elif direction.x != 0:
			animation.play("walk")
		else:
			animation.play("stand")

func _input(_event):
	if Input.is_action_just_pressed("player_ability") and state == State.NORMAL:
		if not no_future:
			state = State.IN_FUTURE
			animation.stop()
			var player_future = load("res://player/player_future.tscn").instance()
			player_future.set_direction(parts.scale.x)
			player_future.connect("end_future", self, "_end_future")
			player_future.connect("future_dead", self, "_future_dead")
			player_future.position = position
			emit_signal("start_future")
			parts.material.set_shader_param("saturation", 0)
			get_parent().add_child(player_future)
			clock.visible = true
			clock.stop = false
		else:
			audio.stream = no_future_sound
			audio.play()
		
	elif Input.is_action_just_pressed("pause_menu"):
		get_parent().get_parent().add_child(load("res://menu/pause_menu.tscn").instance())

func _end_future():
	emit_signal("end_future")
	clock.stop = true
	clock.visible = false
	wait_after_future.start()
	
func _future_dead():
	emit_signal("future_dead")
	clock.stop = true
	clock.visible = false
	wait_after_future.start()
	
func _on_wait_after_future_timeout():
	wait_after_future.stop()
	
	state = State.WAITING
	velocity = Vector2.ZERO
	cooldown.start()
	
func die_explote():
	var physics_player = load("res://player/player_explosion.tscn").instance()
	physics_player.position = position
	if state == State.WAITING:
		physics_player.set_waiting()
	get_parent().add_child(physics_player)
	emit_signal("die_explote")
	queue_free()

func _on_hitbox_area_entered(area):
	if area.owner.name.begins_with("bullet"):
		if area.owner.is_future != null and not area.owner.is_future:
			call_deferred("die_explote")
	else:
		call_deferred("die_explote")

func _on_cooldown_timeout():
	state = State.NORMAL
	parts.material.set_shader_param("saturation", 1)

func _on_trigger_zone_area_entered(area):
	if area.get_parent().name.begins_with("platform") and not area.get_parent().is_future:
		platform = area.get_parent()
	elif area.owner.name.begins_with("jump"):
		velocity += area.owner.BOOST
		audio.stream = jumpad_sound
		audio.play()

func _on_trigger_zone_area_exited(area):
	if area.get_parent().name.begins_with("platform") and not area.get_parent().is_future:
		platform = null
		
func timer_end():
	var physics_player = load("res://player/player_explosion.tscn").instance()
	physics_player.position = position
	physics_player.set_waiting()
	physics_player.timer_end = true
	get_parent().add_child(physics_player)
	emit_signal("die_explote")
	queue_free()

func little_time():
	JUMP -= OLD if JUMP >= 90.0 else 0.0
	MAX_SPEED -= OLD if MAX_SPEED >= 60.0 else 0.0
	ACCELERATION -= OLD if ACCELERATION >= 80.0 else 0.0
	parts.material.set_shader_param("saturation", parts.material.get_shader_param("saturation") - OLD)
