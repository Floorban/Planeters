extends UpgradeEffect
class_name TaskCapacityEffect

@export var bonus_per_level := 1

func apply(level: int) -> void:
	GameManager.task_manager.add_task_capacity(level * bonus_per_level)
