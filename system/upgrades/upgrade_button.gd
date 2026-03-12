@tool
extends TextureButton
class_name UpgradeButton

signal show_upgrade_info(task: Task)
signal hide_upgrade_info()

@onready var upgrade_level: Label = $UpgradeLevel 
@onready var upgrade_branch: Line2D = $UpgradeBranch

@export var upgrade: UpgradeData
var level := 0:
	set(value):
		level = clampi(value, 0, upgrade.max_level)
		upgrade_level.text = str(level) + "/" + str(upgrade.max_level)

var pressed_tween : Tween


func _ready() -> void:
	level = 0
	mouse_entered.connect(_on_mouse_enter)
	mouse_exited.connect(_on_mouse_exited)
	pressed.connect(_on_pressed)
	_init_line()
	if upgrade:
		texture_normal = upgrade.upgrade_icon
	if not Engine.is_editor_hint():
		if get_parent() is UpgradeButton:
			hide()


func _init_line() -> void:
	var p = get_parent()
	if p is not UpgradeButton:
		upgrade_branch.visible = false
		return
		
	upgrade_branch.visible = true
	upgrade_branch.clear_points()
	var my_center = size / 2
	var parent_center = -position + (p.size / 2)
	
	upgrade_branch.add_point(my_center)
	upgrade_branch.add_point(parent_center)
	upgrade_branch.show_behind_parent = true
	upgrade_branch.top_level = false


func _on_mouse_enter() -> void:
	show_upgrade_info.emit(upgrade)


func _on_mouse_exited() -> void:
	hide_upgrade_info.emit()


func _on_pressed() -> void:
	if level == upgrade.max_level or not GameManager.stats_manager.can_pay(upgrade.costs):
		Audio.create_audio(SFXData.SOUND_EFFECT_TYPE.BTN_FAIL)
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
			u.unlock_effect()


func unlock_effect() -> void:
	if pressed_tween:
		pressed_tween.kill()

	pressed_tween = create_tween().set_ease(Tween.EASE_OUT)
	pressed_tween.tween_property(self, "scale", Vector2.ONE * 1.25, 0.12)
	pressed_tween.tween_property(self, "scale", Vector2.ONE , 0.08)
