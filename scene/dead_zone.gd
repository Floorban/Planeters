extends Area2D


func _ready() -> void:
	body_entered.connect(_on_character_entered)


func _on_character_entered(body) -> void:
	if body is Character:
		if body.state == Character.CharacterState.ESCAPING:
			body.queue_free()
			print("free")
