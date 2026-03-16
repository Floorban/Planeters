class_name BuildingData
extends UpgradeData

enum BuildingType {
	None,
	Recruit,
	Sacrifice,
	Build
}

@export var building_type : BuildingType
@export var texture_frames : SpriteFrames

func apply_upgrade_effect(current_level: int) -> void:
	#Audio.create_audio(SFXData.SOUND_EFFECT_TYPE.UPGRADE_PURCHASE)
	GameManager.building_manager.get_new_building(self)
