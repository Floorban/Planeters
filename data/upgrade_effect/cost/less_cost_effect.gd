extends UpgradeEffect
class_name LessCostEffect

@export var stat_change: StatChange

func apply(level: int) -> void:
	GameManager.stats_manager.modify_cost(stat_change.stat, stat_change.amount)
