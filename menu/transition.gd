extends ColorRect

onready var animation = $animation_player
signal transition_end

func _ready():
	var s = get_canvas_item()
	VisualServer.canvas_item_set_draw_index(s, 200)
	VisualServer.canvas_item_set_z_index(s, 200)

func _in():
	animation.play("transition_in")

func _out():
	animation.play("transition_out")

func _on_animation_player_animation_finished(_anim_name):
	emit_signal("transition_end")
