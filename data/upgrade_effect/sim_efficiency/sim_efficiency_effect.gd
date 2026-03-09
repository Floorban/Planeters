extends UpgradeEffect
class_name SimEfficiencyEffect

enum ModifierType { RECRUIT_INTERVAL, COIN_INTERVAL }

@export var modifier_type: ModifierType
@export var change_amount: float
@export var bonus_per_level := 1.0


func apply(_level: int) -> void:
	var final_change = change_amount * bonus_per_level
	match modifier_type:
		ModifierType.RECRUIT_INTERVAL:
			GameManager.sim_manager.modify_recruit_interval(final_change)
		ModifierType.COIN_INTERVAL:
			GameManager.sim_manager.modify_coin_interval(final_change)
