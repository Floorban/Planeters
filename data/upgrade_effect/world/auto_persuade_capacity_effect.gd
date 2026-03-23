extends UpgradeEffect
class_name AutoPersuadeCapacityEffect

@export var amount := 1


func apply(_level: int) -> void:
	GameManager.world_manager.add_auto_persuade_capacity(amount)
