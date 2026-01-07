extends Camera2D
class_name UICamera

var dragging := false
var last_mouse_pos := Vector2.ZERO
@export var drag_speed := 1.0

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if event.pressed:
			dragging = true
			last_mouse_pos = event.position
		else:
			dragging = false

	if event is InputEventMouseMotion and dragging:
		var delta:Vector2 = event.position - last_mouse_pos
		global_position -= delta * drag_speed
		last_mouse_pos = event.position
