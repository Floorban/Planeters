@tool
class_name BuildingButton
extends TextureButton

signal show_building_info(building_data: BuildingData)
signal hide_building_info()

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
	if not GameManager.stats_manager.can_pay(building_data.costs):
		Audio.create_audio(SFXData.SOUND_EFFECT_TYPE.BTN_FAIL)
		return

	self_modulate = Color.LIGHT_GREEN
	building_data.apply_upgrade_effect(0)
	GameManager.stats_manager.pay_costs(building_data.costs)
