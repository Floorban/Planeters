extends Resource
class_name UpgradeData

@export var upgrade_name: String
@export var upgrade_description: String
@export var max_level := 3

@export var costs: Array[StatChange]
@export var effects: Array[UpgradeEffect]


func apply_upgrade_effect(current_level: int) -> void:
	if effects.is_empty():
		push_error("no upgrade effects in the array")
		return
	
	for e in effects:
		e.apply(clampi(current_level, 1, max_level))
