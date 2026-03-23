class_name Cultist
extends Character

var auto_sacrifice_slot: BuildingSlot
var is_queued_for_sacrifice := false
var auto_persuade_target: Outsider
var auto_persuade_timer := 0.0
var auto_persuade_interval := 1.0
var auto_behaviour_disabled := false
var is_pausing_persuade_target := false


func _process(delta: float) -> void:
	super._process(delta)
	_process_auto_sacrifice()
	_process_auto_persuade(delta)


func _handle_selected(is_selected: bool) -> void:
	#if not is_selected:
		#return
	clear_current_behaviour(true)
	state = CharacterState.BEING_DRAGGED
	selected.emit()
	character_sprite.play("hang")
	character_hang()


func _handle_deselected() -> void:
	if state == CharacterState.BEING_KILLED:
		return
	is_hover_paused = false
	state = CharacterState.LANDING
	deselected.emit()
	character_sprite.play("land")
	await character_land()
	if state == CharacterState.LANDING:
		state = CharacterState.WANDERING


func _handle_right_selected() -> void:
	if has_active_behaviour():
		clear_current_behaviour(true)
		return
	auto_behaviour_disabled = false
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
	elif auto_persuade_target:
		lines.append("Right click: auto persuading outsider")
	return lines


func assign_auto_sacrifice(slot: BuildingSlot) -> void:
	clear_current_behaviour(false)
	auto_behaviour_disabled = false
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


func clear_auto_persuade_target() -> void:
	if is_pausing_persuade_target and auto_persuade_target and is_instance_valid(auto_persuade_target):
		auto_persuade_target.set_persuasion_paused(false)
	is_pausing_persuade_target = false
	auto_persuade_target = null
	auto_persuade_timer = 0.0
	if state == CharacterState.AUTO_MOVING or state == CharacterState.WAITING_IN_QUEUE:
		state = CharacterState.IDLE


func clear_current_behaviour(disable_auto := false) -> void:
	clear_auto_sacrifice_assignment()
	clear_auto_persuade_target()
	if disable_auto:
		auto_behaviour_disabled = true


func has_active_behaviour() -> bool:
	return auto_sacrifice_slot != null or auto_persuade_target != null


func has_auto_persuade_behavior() -> bool:
	return auto_persuade_target != null


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


func _process_auto_persuade(delta: float) -> void:
	if auto_sacrifice_slot:
		return
	if auto_behaviour_disabled:
		clear_auto_persuade_target()
		return
	if GameManager.world_manager.auto_persuade_capacity <= 0:
		clear_auto_persuade_target()
		return
	if auto_persuade_target == null or not is_instance_valid(auto_persuade_target) or not GameManager.world_manager.outsiders.has(auto_persuade_target):
		auto_persuade_target = GameManager.world_manager.get_auto_persuade_target(self)
		is_pausing_persuade_target = false
		auto_persuade_timer = 0.0
	if auto_persuade_target == null:
		return
	target_position = auto_persuade_target.global_position
	if global_position.distance_to(target_position) <= stop_distance + 10.0:
		state = CharacterState.WAITING_IN_QUEUE
		if not is_pausing_persuade_target:
			auto_persuade_target.set_persuasion_paused(true)
			is_pausing_persuade_target = true
		character_sprite.play("chat")
		auto_persuade_timer -= delta
		if auto_persuade_timer <= 0.0:
			auto_persuade_target.apply_trust_click(GameManager.world_manager.auto_persuade_trust_power)
			auto_persuade_timer = auto_persuade_interval
	else:
		if is_pausing_persuade_target:
			auto_persuade_target.set_persuasion_paused(false)
			is_pausing_persuade_target = false
		state = CharacterState.AUTO_MOVING
