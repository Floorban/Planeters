extends UpgradeEffect
class_name SacrificeMoreEffect

@export var task: Task
@export var extra_scale_per_level := 1.0

func apply(_level: int) -> void:
	if not GameManager.task_manager.task_scale_multipliers.has(task):
		GameManager.task_manager.task_scale_multipliers[task] = 1.0
	GameManager.task_manager.task_scale_multipliers[task] += extra_scale_per_level
