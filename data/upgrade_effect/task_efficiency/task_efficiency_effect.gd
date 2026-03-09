extends UpgradeEffect
class_name TaskEfficiencyEffect

@export var task: Task
@export var change_amount: float
@export var bonus_per_level := 1


func apply(_level: int) -> void:
	GameManager.task_manager.modify_duration(task, change_amount * bonus_per_level)
