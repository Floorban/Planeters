extends UpgradeEffect
class_name TaskCapacityEffect

@export var amount := 1

func apply(_level: int) -> void:
	GameManager.task_manager.add_task_capacity(amount)
