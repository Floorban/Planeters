@tool
class_name BuildingButton
extends TextureButton

signal show_building_info(building_data: BuildingData)
signal hide_building_info()
signal purchase_requested(building_data: BuildingData)

@export var building_data: BuildingData


func _ready() -> void:
	mouse_entered.connect(_on_mouse_enter)
	mouse_exited.connect(_on_mouse_exited)
	pressed.connect(_on_pressed)
	if building_data:
		texture_normal = building_data.texture_frames.get_frame_texture("interact", 0)


func _on_mouse_enter() -> void:
	show_building_info.emit(building_data)


func _on_mouse_exited() -> void:
	hide_building_info.emit()


func _on_pressed() -> void:
	purchase_requested.emit(building_data)


func refresh_visual_state(can_afford: bool, can_buy: bool, is_selected: bool) -> void:
	disabled = false
	if is_selected:
		self_modulate = Color(0.93, 0.86, 0.42, 1.0)
		mouse_default_cursor_shape = Control.CURSOR_ARROW
		tooltip_text = "Currently placing this building"
	elif can_buy and can_afford:
		self_modulate = Color(1.0, 1.0, 1.0, 1.0)
		mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		tooltip_text = "Buy and place this building"
	elif not can_afford:
		self_modulate = Color(0.65, 0.42, 0.42, 1.0)
		mouse_default_cursor_shape = Control.CURSOR_FORBIDDEN
		tooltip_text = "You cannot afford this building yet"
	else:
		self_modulate = Color(0.55, 0.55, 0.55, 1.0)
		mouse_default_cursor_shape = Control.CURSOR_FORBIDDEN
		tooltip_text = "Finish placing the current building first"
