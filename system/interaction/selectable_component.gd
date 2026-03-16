class_name SelectableComponent
extends Area2D

signal hover_change(hovered: bool)
signal select(selected: bool)

var is_selected := false


func _ready() -> void:
	mouse_entered.connect(_on_mouse_enter)
	mouse_exited.connect(_on_mouse_exit)
	input_event.connect(_on_select)


func _on_mouse_enter() -> void:
	if is_selected:
		return
	hover_change.emit(true)


func _on_mouse_exit() -> void:
	if is_selected:
		return
	hover_change.emit(false)


func _on_select(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("left_click"):
		is_selected = not is_selected
		select.emit(is_selected)
