extends UpgradeEffect
class_name TrustClickEffect

@export var change_amount := 0.5


func apply(_level: int) -> void:
	GameManager.world_manager.modify_outsider_trust_click_power(change_amount)
