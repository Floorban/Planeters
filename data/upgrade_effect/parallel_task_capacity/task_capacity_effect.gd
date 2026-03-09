extends UpgradeEffect
class_name TaskCapacityEffect

func apply(level: int) -> void:
	GameManager.task_manager.add_task_capacity(level)
