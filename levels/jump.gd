extends Node2D
export (Vector2) var BOOST: Vector2 = Vector2(0, -80)

func _ready():
	$particles.gravity = BOOST
