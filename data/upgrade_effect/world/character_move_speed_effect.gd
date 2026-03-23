extends UpgradeEffect
class_name CharacterMoveSpeedEffect

@export var change_amount := 0.15


func apply(_level: int) -> void:
	GameManager.world_manager.modify_character_move_speed(change_amount)
