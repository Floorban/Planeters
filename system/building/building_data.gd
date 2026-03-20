class_name BuildingData
extends Resource

enum BuildingType {
	None,
	Recruit,
	Sacrifice,
	Build,
	Bell,
	Door
}

@export var building_type : BuildingType
@export var texture_frames : SpriteFrames
@export var fill_start : float = 0.0
@export var fill_end : float = 1.0

@export var costs : Array[StatChange]
@export var task : Task
@export var cooldown := 5.0

@export var interaction_sfx : SFXData.SOUND_EFFECT_TYPE

func can_apply_effect() -> bool:
	if building_type == BuildingType.Build:
		return GameManager.world_manager != null and GameManager.world_manager.has_locked_building_slot()
	return GameManager.building_manager.cur_building == null

func apply_upgrade_effect(_current_level: int) -> void:
	if interaction_sfx: Audio.create_audio(interaction_sfx)
	if building_type == BuildingType.Build:
		GameManager.world_manager.unlock_next_building_slot()
		return
	GameManager.building_manager.get_new_building(self)
