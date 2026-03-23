extends UpgradeEffect
class_name BuildingEfficiencyEffect

@export var building_type: BuildingData.BuildingType
@export var change_amount := 0.25


func apply(_level: int) -> void:
	GameManager.building_manager.modify_building_cooldown_efficiency(building_type, change_amount)
