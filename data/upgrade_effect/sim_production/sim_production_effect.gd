extends UpgradeEffect
class_name SimProductionEffect

enum RateType { RECRUIT, COIN }

@export var type: RateType
@export var change_per_level: float = 0.05

func apply(_level: int) -> void:
	match type:
		RateType.RECRUIT:
			GameManager.sim_manager.modify_recruit_rate(change_per_level)
		RateType.COIN:
			GameManager.sim_manager.modify_coin_rate(change_per_level)
