class_name FadeInOutComponent
extends Node

@export var target : Node

var is_hovering := false
var is_opened := false
var panel_og_pos : Vector2
@export var panel_folded_pos : Vector2
@export var panel_unfolded_pos : Vector2
var panel_tween: Tween

var can_close_callable : Callable

func _ready() -> void:
	panel_og_pos = target.global_position


func _on_panel_toggle(toggled_on: bool) -> void:
	if toggled_on: _open_panel()
	else: _close_panel()
	is_hovering = toggled_on


func _open_panel() -> void:
	if is_hovering:
		return
	if panel_tween: panel_tween.kill()
	panel_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	panel_tween.tween_property(target, "global_position", panel_og_pos + panel_unfolded_pos, 0.3)
	is_opened = true


func _close_panel() -> void:
	#if not is_hovering:
		#return
	if can_close_callable and not can_close_callable.call():
		return

	if panel_tween: panel_tween.kill()
	panel_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	panel_tween.tween_property(target, "global_position", panel_og_pos +panel_folded_pos, 0.2)
	
	panel_tween.tween_callback(func(): target.global_position = panel_og_pos + panel_folded_pos)
	is_opened = false
