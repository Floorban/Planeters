class_name Cultist
extends Character


func _handle_selected(is_selected: bool) -> void:
	#if not is_selected:
		#return
	state = CharacterState.BEING_DRAGGED
	selected.emit()
	character_sprite.play("hang")
	character_hang()


func _handle_deselected() -> void:
	if state == CharacterState.BEING_KILLED:
		print("being killed")
		return
	is_hover_paused = false
	state = CharacterState.LANDING
	deselected.emit()
	character_sprite.play("land")
	await character_land()
	if state == CharacterState.LANDING:
		state = CharacterState.WANDERING


func get_hover_title() -> String:
	return "Cult Member"


func get_hover_lines() -> Array[String]:
	return [
		"Passive income source",
		"Drag to altar to sacrifice"
	]
