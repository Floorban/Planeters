class_name BuildingShopManager
extends Control

const DEFAULT_NAME := "Choose A Building"
const DEFAULT_COST := "Hover a building button to inspect its cost."
const DEFAULT_DESCRIPTION := "Buy a structure, then place it on an unlocked slot."
const DEFAULT_REWARD := "Recruiters bring outsiders, altars consume cultists, and chapel work unlocks more room."

@onready var building_name_label: Label = %BuildingNameLabel
@onready var building_cost_label: Label = %BuildingCostLabel
@onready var building_description_label: Label = %BuildingDescriptionLabel
@onready var building_reward_label: Label = %BuildingRewardLabel
@onready var discard_button: Button = %DiscardButton

var building_buttons: Array[BuildingButton] = []
var focused_building_data: BuildingData
@onready var fade_in_out_component: FadeInOutComponent = $FadeInOutComponent


func _ready() -> void:
	fade_in_out_component.can_close_callable = (func(): return not GameManager.building_manager.cur_building)
	await get_tree().process_frame
	if GameManager.stats_manager:
		GameManager.stats_manager.stat_changed.connect(_on_stats_changed)
	_collect_building_buttons(self)
	for button in building_buttons:
		button.show_building_info.connect(_on_show_building_info)
		button.hide_building_info.connect(_on_hide_building_info)
		button.purchase_requested.connect(_on_purchase_requested)
	discard_button.pressed.connect(_on_discard_pressed)
	_set_default_info()
	_refresh_buttons()


func _process(_delta: float) -> void:
	_refresh_buttons()


func _collect_building_buttons(node: Node) -> void:
	for child in node.get_children():
		if child is BuildingButton:
			building_buttons.append(child)
		_collect_building_buttons(child)


func _on_stats_changed(_stat: Stat, _value: int) -> void:
	_refresh_buttons()
	if focused_building_data:
		_apply_building_info(focused_building_data)


func _on_show_building_info(building_data: BuildingData) -> void:
	focused_building_data = building_data
	_apply_building_info(building_data)


func _on_hide_building_info() -> void:
	focused_building_data = null
	_set_default_info()


func _on_purchase_requested(building_data: BuildingData) -> void:
	var has_building_in_hand := GameManager.building_manager.cur_building != null
	var can_afford := _can_afford_costs(building_data.costs)
	var can_apply := building_data.can_apply_effect()
	if has_building_in_hand or not can_apply:
		Audio.create_audio(SFXData.SOUND_EFFECT_TYPE.BTN_FAIL)
		focused_building_data = building_data
		_apply_building_info(building_data, "Place the building you are already holding first.")
		_refresh_buttons()
		return
	if not can_afford:
		Audio.create_audio(SFXData.SOUND_EFFECT_TYPE.BTN_FAIL)
		focused_building_data = building_data
		_apply_building_info(building_data, "Not enough resources to buy this building.")
		_refresh_buttons()
		return

	building_data.apply_upgrade_effect(0)
	GameManager.stats_manager.pay_costs(building_data.costs)
	focused_building_data = building_data
	_apply_building_info(building_data, "Building purchased. Place it on an open slot.")
	_refresh_buttons()


func _refresh_buttons() -> void:
	var held_building: Building = GameManager.building_manager.cur_building
	discard_button.disabled = held_building == null
	discard_button.text = "Trash Held Building" if held_building else "No Building In Hand"
	for button in building_buttons:
		if not button.building_data:
			continue
		var can_afford := _can_afford_costs(button.building_data.costs)
		var can_apply := button.building_data.can_apply_effect()
		var is_selected := held_building != null and held_building.building_data == button.building_data
		var can_buy := can_apply and held_building == null
		button.refresh_visual_state(can_afford, can_buy, is_selected)


func _set_default_info() -> void:
	building_name_label.text = DEFAULT_NAME
	building_cost_label.text = DEFAULT_COST
	building_description_label.text = DEFAULT_DESCRIPTION
	building_reward_label.text = DEFAULT_REWARD


func _on_discard_pressed() -> void:
	if not GameManager.building_manager.discard_current_building():
		return
	focused_building_data = null
	building_name_label.text = "Building Discarded"
	building_cost_label.text = "The held building was removed."
	building_description_label.text = "Buy another structure when you are ready."
	building_reward_label.text = "Tip: slot expansion can come from upgrades or event rewards."
	_refresh_buttons()


func _apply_building_info(building_data: BuildingData, status_override := "") -> void:
	building_name_label.text = _get_building_name(building_data)
	building_cost_label.text = _build_cost_text(building_data, status_override)
	building_description_label.text = _build_description_text(building_data)
	building_reward_label.text = _build_reward_text(building_data)


func _get_building_name(building_data: BuildingData) -> String:
	match building_data.building_type:
		BuildingData.BuildingType.Recruit:
			return "Mailbox"
		BuildingData.BuildingType.Sacrifice:
			return "Altar"
		BuildingData.BuildingType.Build:
			return "Chapel Works"
		_:
			if building_data.task and not building_data.task.task_name.is_empty():
				return tr(building_data.task.task_name)
			return "Building"


func _build_cost_text(building_data: BuildingData, status_override := "") -> String:
	var cost_text := "Cost: Free"
	if not building_data.costs.is_empty():
		var cost_parts: Array[String] = []
		for cost in building_data.costs:
			cost_parts.append("%d %s" % [int(cost.amount), cost.stat.stat_name])
		cost_text = "Cost: %s" % ", ".join(cost_parts)
	if status_override.is_empty():
		return cost_text
	return "%s\n%s" % [cost_text, status_override]


func _can_afford_costs(costs: Array[StatChange]) -> bool:
	if not GameManager.stats_manager:
		return false
	for cost in costs:
		if GameManager.stats_manager.get_stat(cost.stat) < cost.amount:
			return false
	return true


func _build_description_text(building_data: BuildingData) -> String:
	if building_data.task and not building_data.task.task_description.is_empty():
		return tr(building_data.task.task_description)
	match building_data.building_type:
		BuildingData.BuildingType.Recruit:
			return "Attracts outsiders who can be converted into cult members."
		BuildingData.BuildingType.Sacrifice:
			return "Drag a cultist here to perform a ritual sacrifice."
		BuildingData.BuildingType.Build:
			return "Unlocks another place in the church grounds for new structures."
		_:
			return "A structure for your growing cult."


func _build_reward_text(building_data: BuildingData) -> String:
	if building_data.building_type == BuildingData.BuildingType.Build:
		return "Reward: Unlocks 1 additional building slot."
	if building_data.building_type == BuildingData.BuildingType.Sacrifice:
		return "Reward: Converts 1 cult member into ritual rewards after the cooldown."
	if building_data.task and not building_data.task.rewards.is_empty():
		var reward_parts: Array[String] = []
		for reward in building_data.task.rewards:
			reward_parts.append("%d %s" % [int(reward.amount), reward.stat.stat_name])
		return "Reward: %s" % ", ".join(reward_parts)
	return "Reward: Utility building."
