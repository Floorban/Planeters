extends UpgradeEffect
class_name SacrificeMoreEffect

@export var task: Task

func apply(level: int) -> void:
	for c in task.costs:
		GameManager.stats_manager.modify_cost(c.stat, level)
	for r in task.rewards:
		GameManager.stats_manager.modify_reward(r.stat, level)
