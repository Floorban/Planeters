class_name BuildingData
extends Resource

enum BuildingType {
	None,
	Recruit,
	Sacrifice,
	Build
}

@export var building_type : BuildingType
@export var texture_frames : SpriteFrames

@export var costs : Array[StatChange]
@export var task : Task
@export var cooldown := 5.0

func can_apply_effect() -> bool:
	return GameManager.building_manager.cur_building == null

func apply_upgrade_effect(_current_level: int) -> void:
	#Audio.create_audio(SFXData.SOUND_EFFECT_TYPE.UPGRADE_PURCHASE)
	GameManager.building_manager.get_new_building(self)
