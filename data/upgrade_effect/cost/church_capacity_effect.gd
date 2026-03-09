extends UpgradeEffect
class_name ChurchCapacityEffect

@export var extra_capacity_per_level: int = 5

func apply(_level: int) -> void:
	GameManager.sim_manager.modify_church_capacity(extra_capacity_per_level)
