extends SkillEffect
class_name BonusProductionEffect

@export var bonus_per_level := 1

func apply(building: Building, level: int) -> void:
	building.procude_points += bonus_per_level * level
