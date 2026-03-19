class_name Cultist
extends Character

var auto_sacrifice_slot: BuildingSlot
var is_queued_for_sacrifice := false


func _process(delta: float) -> void:
	super._process(delta)
	_process_auto_sacrifice()


func _handle_selected(is_selected: bool) -> void:
	#if not is_selected:
		#return
	clear_auto_sacrifice_assignment()
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


func _handle_right_selected() -> void:
	GameManager.world_manager.assign_cultist_to_sacrifice_queue(self)


func get_hover_title() -> String:
	return "Cult Member"


func get_hover_lines() -> Array[String]:
	var lines : Array[String]  = [
		"Passive income source",
		"Drag to altar to sacrifice"
	]
	if auto_sacrifice_slot:
		lines.append("Right click: assigned to altar")
	return lines


func assign_auto_sacrifice(slot: BuildingSlot) -> void:
	clear_auto_sacrifice_assignment()
	auto_sacrifice_slot = slot
	is_queued_for_sacrifice = false
	if state != CharacterState.BEING_KILLED and state != CharacterState.BEING_DRAGGED:
		state = CharacterState.AUTO_MOVING


func clear_auto_sacrifice_assignment(remove_from_slot := true) -> void:
	if remove_from_slot and auto_sacrifice_slot and is_instance_valid(auto_sacrifice_slot):
		auto_sacrifice_slot.remove_queued_cultist(self)
	auto_sacrifice_slot = null
	is_queued_for_sacrifice = false
	if state == CharacterState.AUTO_MOVING or state == CharacterState.WAITING_IN_QUEUE:
		state = CharacterState.IDLE


func _process_auto_sacrifice() -> void:
	if not auto_sacrifice_slot:
		return
	if not is_instance_valid(auto_sacrifice_slot) or not auto_sacrifice_slot.can_accept_auto_sacrifice():
		clear_auto_sacrifice_assignment(false)
		return
	if state == CharacterState.BEING_KILLED or state == CharacterState.DEAD or state == CharacterState.BEING_DRAGGED:
		return
	target_position = auto_sacrifice_slot.get_queue_world_position(self)
	if is_queued_for_sacrifice:
		if global_position.distance_to(target_position) <= stop_distance + 2.0:
			state = CharacterState.WAITING_IN_QUEUE
			character_sprite.play("idle")
		else:
			state = CharacterState.AUTO_MOVING
		return
	state = CharacterState.AUTO_MOVING
	if global_position.distance_to(target_position) <= stop_distance + 6.0:
		auto_sacrifice_slot.enqueue_auto_sacrifice_cultist(self)
