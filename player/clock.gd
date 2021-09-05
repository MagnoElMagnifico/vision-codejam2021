extends Node2D

export (float) var SPEED: float = 1000
export (float) var MINOR_MARGIN = 10

onready var mayor = $mayor_clock_hand
onready var minor = $minor_clock_hand
var stop = true

func _physics_process(delta):
	if not stop:
		mayor.rotation_degrees += SPEED * delta
		if fmod(mayor.rotation_degrees, 360.0) <= MINOR_MARGIN:
			minor.rotation_degrees += SPEED * delta
