extends SubPanel
class_name UpgradesManager

signal upgrade_changed(upgrade: UpgradeData, level: int)

@export var upgrade_btns: Array[UpgradeButton]
var upgrades: Array[UpgradeData]
var upgrade_levels: Dictionary[UpgradeData, int] = {}

@onready var upgrade_control_label: Label = %UpgradeControlLabel
@onready var upgrade_name_label: Label = %UpgradeNameLabel
@onready var upgrade_cost_label: Label = %UpgradeCostLabel
@onready var upgrade_effect_label: Label = %UpgradeEffectLabel


func _ready() -> void:
	GameManager.upgrades_manager = self
	
	for upgrade_btn in upgrade_btns:
		upgrades.append(upgrade_btn.upgrade)
		upgrade_btn.show_upgrade_info.connect(_show_upgrade_info)
		upgrade_btn.hide_upgrade_info.connect(func(): disable_upgrade_info(true))
		
	for upgrade in upgrades:
		upgrade_levels[upgrade] = 0
	
	disable_upgrade_info(true)


func _show_upgrade_info(upgrade: UpgradeData) -> void:
	disable_upgrade_info(false)
	upgrade_name_label.text = upgrade.upgrade_name
	upgrade_effect_label.text = upgrade.upgrade_description
	
	var cost := 0
	for c in upgrade.costs:
		cost += c.amount
	upgrade_cost_label.text = "$ " + str(cost)


func disable_upgrade_info(disable: bool) -> void:
	upgrade_control_label.visible = disable
	upgrade_name_label.visible = not disable
	upgrade_effect_label.visible = not disable
	upgrade_cost_label.visible = not disable


func unlock(upgrade: UpgradeData) -> void:
	if not can_unlock(upgrade):
		return
	upgrade_levels[upgrade] += 1
	upgrade_changed.emit(upgrade, upgrade_levels[upgrade])


func get_level(upgrade: UpgradeData) -> int:
	return upgrade_levels.get(upgrade, 0)


func is_unlocked(upgrade: UpgradeData) -> bool:
	return get_level(upgrade) > 0


func can_unlock(upgrade: UpgradeData) -> bool:
	return get_level(upgrade) < upgrade.max_level
