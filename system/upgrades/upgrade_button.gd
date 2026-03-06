extends TextureButton
class_name UpgradeButton

@onready var upgrade_level: Label = $UpgradeLevel
@onready var upgrade_branch: Line2D = $UpgradeBranch

@export var upgrade: UpgradeData
var level := 0:
	set(value):
		level = clampi(value, 0, upgrade.max_level)
		upgrade_level.text = str(level) + "/" + str(upgrade.max_level)


func _ready() -> void:
	if get_parent() is UpgradeButton:
		hide()
	_init_line()
	pressed.connect(_on_pressed)


func _init_line() -> void:
	var p := get_parent()
	if p is not UpgradeButton:
		return
		
	upgrade_branch.clear_points()
	await get_tree().process_frame
	
	var my_center = global_position + size / 2
	upgrade_branch.add_point(upgrade_branch.to_local(my_center))
	
	var parent_global_center = p.global_position + (p.size / 2)
	var parent_local_pos = upgrade_branch.to_local(parent_global_center)
	upgrade_branch.add_point(parent_local_pos)
	
	#skill_branch.add_point(global_position + size / 2)
	#skill_branch.add_point(p.global_position + p.size / 2)


func _on_pressed() -> void:
	if level == upgrade.max_level or not GameManager.stats_manager.can_pay(upgrade.costs):
		return
	self_modulate = Color.LIGHT_GREEN
	upgrade_branch.default_color = Color.GREEN
	level = min(level + 1, upgrade.max_level)
	upgrade.apply_upgrade_effect(level)
	GameManager.stats_manager.pay_costs(upgrade.costs)
	GameManager.upgrades_manager.unlock(upgrade)
	_unlock_next_upgrades()


func _unlock_next_upgrades() -> void:
	var upgrades = get_children()
	for u in upgrades:
		if u is UpgradeButton and level == upgrade.max_level:
			u.disabled = false
			u.show()
