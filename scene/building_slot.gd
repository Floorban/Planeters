class_name BuildingSlot
extends Node2D

@onready var slot_sprite: Sprite2D = %SlotSprite
@onready var sprite_material : ShaderMaterial = slot_sprite.material
@onready var selectable_component: SelectableComponent = %SelectableComponent

@export var my_building : Building

var cooldown_timer := 0.0
var cooldown_duration := 5.0
var is_on_cooldown := false
var is_processing_auto_sacrifice := false
var slot_efficiency_multiplier := 1.0 
var is_locked := false
var auto_sacrifice_queue: Array[Cultist] = []

@export var is_static := false

func _ready() -> void:
	selectable_component.hover_change.connect(_on_slot_hovered)
	selectable_component.select.connect(_on_slot_selected)
	selectable_component.deselect.connect(_on_slot_received)
	selectable_component.right_select.connect(
	func():
		if is_static:
			return
		_on_remove_building(my_building)
		my_building = null
	)
	if slot_sprite and sprite_material:
		slot_sprite.material = sprite_material.duplicate()
		sprite_material = slot_sprite.material


func _process(delta: float) -> void:
	_cleanup_auto_sacrifice_queue()
	if is_on_cooldown and my_building:
		cooldown_timer += delta
		var total_time_needed = cooldown_duration / get_cooldown_speed_multiplier()
		var progress_percent = clamp(cooldown_timer / total_time_needed, 0.0, 1.0)
		my_building.set_cooldown_visuals(progress_percent, true)
		if cooldown_timer >= total_time_needed:
			_finish_cooldown()
	elif _can_process_auto_sacrifice():
		_start_auto_sacrifice_from_queue()


func _finish_cooldown() -> void:
	is_on_cooldown = false
	cooldown_timer = 0.0
	if my_building:
		my_building.finish_buildling_cooldown()


func _start_interaction() -> void:
	if not my_building:
		return
	var did_start : bool = GameManager.building_manager.start_task(my_building.building_data.task, my_building)
	if not did_start:
		return
	await my_building.interact_with_building(get_cooldown_speed_multiplier())
	is_on_cooldown = true
	cooldown_timer = 0.0
	if my_building.building_data:
		cooldown_duration = my_building.building_data.cooldown
	my_building.set_cooldown_visuals(0.0, true)


func _place_new_building(held_building: Building) -> void:
	my_building = held_building
	GameManager.building_manager.place_building()
	my_building.global_position = global_position
	sprite_material.set_shader_parameter("outline_mode", 0)
	# Reset cooldown state for new building
	is_on_cooldown = false 
	cooldown_timer = 0.0


func _on_remove_building(building_to_remove: Building) -> void:
	if not building_to_remove:
		return
	_clear_auto_sacrifice_queue()
	GameManager.building_manager.get_new_building(building_to_remove.building_data)
	building_to_remove.queue_free()
	is_on_cooldown = false
	sprite_material.set_shader_parameter("outline_mode", 1)


func _switch_building(current_building: Building, held_building: Building):
	if is_static:
		return
	_place_new_building(held_building)
	_on_remove_building(current_building)


func _on_slot_hovered(hovered: bool) -> void:
	if is_locked:
		return
	if my_building:
		my_building.on_hovered(hovered)
		my_building.set_cooldown_visuals(cooldown_timer / (cooldown_duration / get_cooldown_speed_multiplier()), is_on_cooldown)
		return
	if not GameManager.building_manager.cur_building:
		return
	var mode := 1 if hovered else 0
	sprite_material.set_shader_parameter("outline_mode", mode)


func _on_slot_selected(_selected: bool) -> void:
	if is_locked:
		return
	var held_building = GameManager.building_manager.cur_building
	if selectable_component.is_hovered and held_building:
		if my_building:
			_switch_building(my_building, held_building)
		else:
			_place_new_building(held_building)
	elif my_building  and not held_building:
		if not is_on_cooldown:
			_start_interaction()
		else:
			my_building.interact_failed()


func _on_slot_received() -> void:
	if is_locked:
		return
	if not my_building or my_building.building_data.building_type != BuildingData.BuildingType.Sacrifice:
		return
	var dropped_characters = GameManager.world_manager.get_dragged_characters_for_drop()
	if dropped_characters.is_empty():
		return
	var held_building = GameManager.building_manager.cur_building
	if my_building and not held_building:
		if not is_on_cooldown:
			_start_interaction()
		else:
			my_building.interact_failed()


func set_locked(locked: bool) -> void:
	is_locked = locked
	visible = not locked
	if selectable_component:
		selectable_component.monitoring = not locked
		selectable_component.input_pickable = not locked


func get_cooldown_speed_multiplier() -> float:
	var speed_multiplier := slot_efficiency_multiplier
	if my_building and my_building.building_data:
		speed_multiplier *= GameManager.building_manager.get_building_cooldown_efficiency(my_building.building_data.building_type)
	return max(0.05, speed_multiplier)


func can_accept_auto_sacrifice() -> bool:
	return not is_locked and my_building != null and my_building.building_data != null and my_building.building_data.building_type == BuildingData.BuildingType.Sacrifice


func get_auto_sacrifice_load() -> int:
	return auto_sacrifice_queue.size() + (1 if is_on_cooldown else 0)


func get_queue_world_position(cultist: Cultist = null) -> Vector2:
	var index := auto_sacrifice_queue.find(cultist)
	if index < 0:
		index = auto_sacrifice_queue.size()
	return global_position + Vector2(0, 18 + (index * 14))


func enqueue_auto_sacrifice_cultist(cultist: Cultist) -> void:
	if not can_accept_auto_sacrifice():
		return
	if not auto_sacrifice_queue.has(cultist):
		auto_sacrifice_queue.append(cultist)
	cultist.auto_sacrifice_slot = self
	cultist.is_queued_for_sacrifice = true
	cultist.state = Character.CharacterState.WAITING_IN_QUEUE


func remove_queued_cultist(cultist: Cultist) -> void:
	auto_sacrifice_queue.erase(cultist)


func get_queued_cultists_for_sacrifice(amount: int) -> Array[Character]:
	var victims: Array[Character] = []
	for cultist in auto_sacrifice_queue:
		if victims.size() >= amount:
			break
		if cultist and is_instance_valid(cultist):
			victims.append(cultist)
	return victims


func _can_process_auto_sacrifice() -> bool:
	return can_accept_auto_sacrifice() and not auto_sacrifice_queue.is_empty() and GameManager.building_manager.cur_building == null and not is_processing_auto_sacrifice


func _start_auto_sacrifice_from_queue() -> void:
	var victims := get_queued_cultists_for_sacrifice(GameManager.building_manager.get_sacrifice_member_cost(my_building.building_data.task))
	if victims.is_empty():
		return
	is_processing_auto_sacrifice = true
	var lead_cultist := victims[0] as Character
	var did_start : bool = GameManager.building_manager.start_task(my_building.building_data.task, my_building, lead_cultist, victims)
	if not did_start:
		is_processing_auto_sacrifice = false
		return
	for victim in victims:
		if victim is Cultist:
			remove_queued_cultist(victim)
			victim.clear_auto_sacrifice_assignment(false)
	await my_building.interact_with_building(get_cooldown_speed_multiplier())
	is_on_cooldown = true
	cooldown_timer = 0.0
	if my_building.building_data:
		cooldown_duration = my_building.building_data.cooldown
	my_building.set_cooldown_visuals(0.0, true)
	is_processing_auto_sacrifice = false


func _cleanup_auto_sacrifice_queue() -> void:
	var valid_queue: Array[Cultist] = []
	for cultist in auto_sacrifice_queue:
		if cultist and is_instance_valid(cultist) and cultist.auto_sacrifice_slot == self:
			valid_queue.append(cultist)
	auto_sacrifice_queue = valid_queue


func _clear_auto_sacrifice_queue() -> void:
	for cultist in auto_sacrifice_queue:
		if cultist and is_instance_valid(cultist):
			cultist.clear_auto_sacrifice_assignment(false)
	auto_sacrifice_queue.clear()
	
	
