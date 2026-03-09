extends UpgradeEffect
class_name BonusProductionEffect

@export var stat_change: StatChange
@export var bonus_per_level := 1

func apply(level: int) -> void:
	GameManager.stats_manager.modify_reward(stat_change.stat, stat_change.amount * level * bonus_per_level)
