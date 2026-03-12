extends UpgradeEffect
class_name BonusProductionEffect

@export var stat_change: StatChange

func apply(_level: int) -> void:
	GameManager.stats_manager.modify_reward(stat_change.stat, stat_change.amount)
