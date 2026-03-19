class_name BuildSlotEffect
extends UpgradeEffect

func apply(_level: int) -> void:
	GameManager.world_manager.unlock_next_building_slot()
