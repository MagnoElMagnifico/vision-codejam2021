extends Area2D

signal end_screen
onready var block_collision = $block/collision

func _on_end_screen_zone_area_entered(area):
	if area.get_parent().name == "player":
		call_deferred("disable_end_screen_zone")
		emit_signal("end_screen")
		
func disable_end_screen_zone():
	monitoring = false
	block_collision.disabled = false
