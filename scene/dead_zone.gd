extends Area2D


func _ready() -> void:
	body_entered.connect(_on_character_entered)


func _on_character_entered(body) -> void:
	if body is Character:
		if body is Outsider and body.state == Character.CharacterState.ESCAPING:
			GameManager.world_manager.remove_outsider(body)
			return
		if body.state == Character.CharacterState.ESCAPING:
			body.state = Character.CharacterState.BEING_KILLED
