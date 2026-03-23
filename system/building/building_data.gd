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
@export var building_effects : Array[BuildingEffect]
@export var cooldown := 5.0

@export var sfx_interaction : SoundEvent


func can_apply_effect() -> bool:
	if building_type == BuildingType.Build:
		return GameManager.world_manager != null and GameManager.world_manager.has_locked_building_slot()
	return GameManager.building_manager.cur_building == null


func apply_effects() -> void:
	if sfx_interaction: Audio.play(sfx_interaction.name)
	if building_effects.is_empty():
		return
	for e in building_effects:
		e.apply()
