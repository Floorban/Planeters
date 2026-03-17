class_name SelectableComponent
extends Area2D

signal hover_change(hovered: bool)
signal select(selected: bool)
signal right_select()

var is_hovered := false
var is_selected := false

var margin := 2.0

@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	mouse_entered.connect(_on_mouse_enter)
	mouse_exited.connect(_on_mouse_exit)
	input_event.connect(_on_select)


#func _process(_delta: float) -> void:
	#var window_size = Vector2(DisplayServer.window_get_size())
	#var mouse_pos = get_viewport().get_mouse_position()
	#
	#var min_bound = Vector2(margin, margin)
	#var max_bound = window_size - Vector2(margin, margin)
	#
	#if mouse_pos.x < min_bound.x or mouse_pos.y < min_bound.y or \
	   #mouse_pos.x > max_bound.x or mouse_pos.y > max_bound.y:
		#DisplayServer.mouse_set_mode(DisplayServer.MouseMode.MOUSE_MODE_CONFINED_HIDDEN)
	#else:
		#DisplayServer.mouse_set_mode(DisplayServer.MouseMode.MOUSE_MODE_VISIBLE)
		#
	#if is_hovered:
		#var is_mouse_really_here = false
		#
		#for child in get_children():
			#if child is CollisionShape2D and child.shape:
				#var local_mouse = child.to_local(mouse_pos)
				#if child.shape.get_rect().has_point(local_mouse):
					#is_mouse_really_here = true
					#break
		#
		#if not is_mouse_really_here:
			#_set_hover(false)


func _on_mouse_enter() -> void:
	_set_hover(true)


func _on_mouse_exit() -> void:
	_set_hover(false)


func _set_hover(state: bool) -> void:
	if is_hovered == state: return
	is_hovered = state
	hover_change.emit(is_hovered)


func _on_select(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("left_click"):
		is_selected = not is_selected
		select.emit(is_selected)
	elif event.is_action_pressed("right_click"):
		right_select.emit()
