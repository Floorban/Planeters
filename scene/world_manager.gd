class_name WorldManager
extends Node2D

@export var cultist_scene : PackedScene
@export var outsider_scene : PackedScene
@export var square_center : Marker2D
@export var exit_point : Marker2D

var cultists : Array[Cultist] = []
var outsiders : Array[Outsider] = []
var outsider_pool := 0
@export var max_visible_outsiders := 40
@export var outsider_trust_click_power := 1.0
var character_speed_multiplier := 1.0
var auto_persuade_capacity := 0
var auto_persuade_trust_power := 1.0
var allow_shared_auto_persuasion := false
@export var max_max_visible_cultists := 500
var max_visible_cultists := 0
var current_members := 0

var cur_characters: Array[Character] = []
var last_released_characters: Array[Character] = []
var building_slots: Array[BuildingSlot] = []
@onready var hover_panel: CharacterHoverPanel = $CanvasLayer/CharacterHoverPanel


func _ready():
	await get_tree().process_frame
	GameManager.world_manager = self
	GameManager.stats_manager.stat_changed.connect(_on_stat_changed)
	building_slots = _get_building_slots()
	max_visible_cultists = GameManager.sim_manager.members_per_church * GameManager.stats_manager.get_stat(GameManager.sim_manager.church_stat)
	current_members = cultists.size()
	_refresh_building_slots()
	_on_stat_changed(GameManager.sim_manager.member_stat, GameManager.stats_manager.get_stat(GameManager.sim_manager.member_stat))


func _on_stat_changed(stat: Stat, value: float):
	if stat != GameManager.sim_manager.member_stat:
		if stat == GameManager.sim_manager.church_stat:
			max_visible_cultists = GameManager.sim_manager.members_per_church * GameManager.stats_manager.get_stat(stat)
			_refresh_building_slots()
		return

	var target := int(value)

	if target > current_members and current_members < max_max_visible_cultists:
		var amount_to_spawn := target - current_members
		if amount_to_spawn > 0:
			_spawn_cultists(amount_to_spawn)
	elif target < current_members:
		if randf() > 0.8:
			_remove_members(max(1, current_members - target))
		else:
			sacrifice_member()


func _spawn_cultists(amount: int) -> void:
	if current_members + amount > max_max_visible_cultists:
		return
	
	current_members += amount
	
	for i in amount:
		var c := cultist_scene.instantiate() as Cultist
		add_child(c)
		var rand_scale := randf_range(1.3, 1.7)
		c.scale = Vector2(rand_scale, rand_scale)
		c.set_speed_multiplier(character_speed_multiplier)
		_connect_cultist_signals(c)
		c.global_position = exit_point.global_position + Vector2(randf_range(-400, 400), randf_range(-50, 20))
		c.target_position = get_random_church_position()
		c.state = Character.CharacterState.WANDERING
		cultists.append(c)


func _remove_members(amount):
	if amount < 0:
		return
	current_members -= amount
	
	for i in amount:
		if cultists.is_empty():
			return

		var c : Cultist = cultists.pop_back()
		c.state = Character.CharacterState.ESCAPING
		c.target_position = exit_point.global_position


func sacrifice_member():
	if cultists.is_empty():
		return
	
	var c : Cultist = cultists.pick_random()
	c.start_being_killed()
	cultists.erase(c)
	current_members -= 1


func get_random_church_position() -> Vector2:
	return square_center.global_position + Vector2(randf_range(-200, 200),randf_range(-40, 100))

	
func get_dragged_characters_for_drop() -> Array[Character]:
	var dragged: Array[Character] = []
	for character in cur_characters:
		if character and is_instance_valid(character):
			dragged.append(character)
	if not dragged.is_empty():
		return dragged
	for character in last_released_characters:
		if character and is_instance_valid(character):
			dragged.append(character)
	return dragged


func consume_selected_character_for_sacrifice(character: Character) -> bool:
	return consume_characters_for_sacrifice(character, 1)


func consume_characters_for_sacrifice(character: Character, amount: int, preferred_victims: Array[Character] = []) -> bool:
	if amount <= 0:
		return false
	if not character or not is_instance_valid(character):
		return false
	if not cultists.has(character):
		return false
	if cultists.size() < amount:
		return false
	var victims := _get_preferred_cultists_for_sacrifice(preferred_victims, amount)
	if victims.is_empty():
		victims = _get_dragged_cultists_for_sacrifice(amount)
	if victims.is_empty():
		victims.append(character)
	elif not victims.has(character) and victims.size() < amount:
		victims.append(character)
	while victims.size() < amount:
		var candidate : Cultist = cultists.pick_random()
		if victims.has(candidate):
			continue
		victims.append(candidate)
	for victim in victims:
		cultists.erase(victim)
		_remove_dragged_character(victim)
		if victim is Cultist:
			victim.clear_auto_sacrifice_assignment()
		victim.start_being_killed()
	current_members = max(0, current_members - victims.size())
	GameManager.stats_manager.spend_stat(GameManager.sim_manager.member_stat, victims.size())
	return true


func _get_building_slots() -> Array[BuildingSlot]:
	var found_slots: Array[BuildingSlot] = []
	var slots_parent := get_node_or_null("Church/BuildingSlots")
	if not slots_parent:
		return found_slots
	for child in slots_parent.get_children():
		if child is BuildingSlot:
			found_slots.append(child)
	return found_slots


func _refresh_building_slots() -> void:
	if building_slots.is_empty():
		return
	var unlocked_slots := int(GameManager.stats_manager.get_stat(GameManager.sim_manager.church_stat))
	for i in range(building_slots.size()):
		building_slots[i].set_locked(i >= unlocked_slots)


func _clear_released_character(character: Character) -> void:
	if character.state == Character.CharacterState.BEING_KILLED:
		return
	last_released_characters.erase(character)


func has_locked_building_slot() -> bool:
	var unlocked_slots := int(GameManager.stats_manager.get_stat(GameManager.sim_manager.church_stat))
	return unlocked_slots < building_slots.size()


func unlock_next_building_slot() -> bool:
	if not has_locked_building_slot():
		return false
	GameManager.stats_manager.add_stat(GameManager.sim_manager.church_stat, 1)
	return true


func spawn_outsider_wave(amount: int) -> void:
	if amount <= 0:
		return
	outsider_pool += amount
	_fill_outsider_slots()


func _fill_outsider_slots() -> void:
	while outsider_pool > 0 and outsiders.size() < max_visible_outsiders:
		_spawn_outsider()
		outsider_pool -= 1


func _spawn_outsider() -> void:
	var outsider := outsider_scene.instantiate() as Outsider
	add_child(outsider)
	var rand_scale := randf_range(1.25, 1.6)
	outsider.scale = Vector2(rand_scale, rand_scale)
	outsider.trust_per_click = outsider_trust_click_power
	outsider.set_speed_multiplier(character_speed_multiplier)
	outsider.global_position = exit_point.global_position + Vector2(randf_range(-400, 400), randf_range(-50, 20))
	outsider.target_position = get_random_church_position()
	outsider.state = Character.CharacterState.WANDERING
	_connect_outsider_signals(outsider)
	outsiders.append(outsider)


func _connect_cultist_signals(cultist: Cultist) -> void:
	cultist.selected.connect(func():
		if not cur_characters.has(cultist):
			cur_characters.append(cultist)
		last_released_characters.erase(cultist)
	)
	cultist.deselected.connect(func():
		cur_characters.erase(cultist)
		if not last_released_characters.has(cultist):
			last_released_characters.append(cultist)
		call_deferred("_clear_released_character", cultist)
	)
	cultist.hover_state_changed.connect(_on_character_hover_changed)


func _connect_outsider_signals(outsider: Outsider) -> void:
	outsider.converted.connect(_on_outsider_converted)
	outsider.expired.connect(_on_outsider_expired)
	outsider.hover_state_changed.connect(_on_character_hover_changed)


func _on_outsider_converted(outsider: Outsider) -> void:
	if not outsiders.has(outsider):
		return
	var convert_amount : int = max(1, outsider.represented_count)
	_transform_outsider_to_cultists(outsider, convert_amount)
	GameManager.stats_manager.add_stat(GameManager.sim_manager.member_stat, convert_amount)
	_fill_outsider_slots()


func _on_outsider_expired(_outsider: Outsider) -> void:
	pass


func remove_outsider(outsider: Outsider, clear_hover := true) -> void:
	if not outsider:
		return
	outsiders.erase(outsider)
	if clear_hover and hover_panel.visible:
		hover_panel.hide_character_info()
	outsider.queue_free()


func _transform_outsider_to_cultists(outsider: Outsider, amount: int) -> void:
	var spawn_position := outsider.global_position
	var spawn_scale := outsider.scale
	remove_outsider(outsider, false)
	for i in amount:
		var cultist := cultist_scene.instantiate() as Cultist
		add_child(cultist)
		cultist.scale = spawn_scale
		cultist.set_speed_multiplier(character_speed_multiplier)
		_connect_cultist_signals(cultist)
		cultist.global_position = spawn_position + Vector2(randf_range(-4, 4), randf_range(-2, 2))
		cultist.target_position = get_random_church_position()
		cultist.state = Character.CharacterState.WANDERING
		cultist.character_sprite.modulate = Color.BLACK
		cultist._handle_deselected()
		cultist.walk_speed += 50
		cultist.run_speed += 50
		cultist.z_index += 1
		cultists.append(cultist)
	current_members += amount


func _on_character_hover_changed(character: Character, hovered: bool) -> void:
	if not hovered:
		hover_panel.hide_character_info()
		return
	hover_panel.show_character_info(character.get_hover_title(), character.get_hover_lines(), character)


func modify_outsider_trust_click_power(amount: float) -> void:
	outsider_trust_click_power = max(0.1, outsider_trust_click_power + amount)
	for outsider in outsiders:
		outsider.trust_per_click = outsider_trust_click_power


func modify_character_move_speed(amount: float) -> void:
	character_speed_multiplier = max(0.1, character_speed_multiplier + amount)
	for cultist in cultists:
		cultist.set_speed_multiplier(character_speed_multiplier)
	for outsider in outsiders:
		outsider.set_speed_multiplier(character_speed_multiplier)


func add_auto_persuade_capacity(amount: int) -> void:
	auto_persuade_capacity = max(0, auto_persuade_capacity + amount)
	for cultist in cultists:
		if cultist and is_instance_valid(cultist) and not cultist.auto_sacrifice_slot:
			cultist.auto_behaviour_disabled = false


func get_auto_persuade_target(cultist: Cultist) -> Outsider:
	if auto_persuade_capacity <= 0:
		return null
	var already_active := cultist.has_auto_persuade_behavior()
	if not already_active and get_active_auto_persuader_count() >= auto_persuade_capacity:
		return null
	var best_target: Outsider
	for outsider in outsiders:
		if outsider == null or not is_instance_valid(outsider):
			continue
		if outsider.state == Character.CharacterState.BEING_KILLED or outsider.state == Character.CharacterState.DEAD or outsider.state == Character.CharacterState.ESCAPING:
			continue
		if not allow_shared_auto_persuasion and _is_outsider_targeted_by_other_cultist(outsider, cultist):
			continue
		if best_target == null or cultist.global_position.distance_squared_to(outsider.global_position) < cultist.global_position.distance_squared_to(best_target.global_position):
			best_target = outsider
	return best_target


func assign_cultist_to_sacrifice_queue(cultist: Cultist) -> bool:
	if not cultist or not is_instance_valid(cultist):
		return false
	var slot := get_best_sacrifice_slot(cultist.global_position)
	if slot == null:
		return false
	cultist.assign_auto_sacrifice(slot)
	return true


func get_best_sacrifice_slot(origin: Vector2) -> BuildingSlot:
	var best_slot: BuildingSlot
	for slot in building_slots:
		if slot == null or not is_instance_valid(slot) or not slot.can_accept_auto_sacrifice():
			continue
		if best_slot == null:
			best_slot = slot
			continue
		var slot_load := slot.get_auto_sacrifice_load()
		var best_load := best_slot.get_auto_sacrifice_load()
		if slot_load < best_load:
			best_slot = slot
			continue
		if slot_load == best_load and origin.distance_squared_to(slot.global_position) < origin.distance_squared_to(best_slot.global_position):
			best_slot = slot
	return best_slot


func _get_dragged_cultists_for_sacrifice(amount: int) -> Array[Character]:
	var victims: Array[Character] = []
	for character in get_dragged_characters_for_drop():
		if victims.size() >= amount:
			break
		if not (character is Cultist):
			continue
		if not cultists.has(character):
			continue
		victims.append(character)
	return victims


func _get_preferred_cultists_for_sacrifice(preferred_victims: Array[Character], amount: int) -> Array[Character]:
	var victims: Array[Character] = []
	for character in preferred_victims:
		if victims.size() >= amount:
			break
		if not character or not is_instance_valid(character):
			continue
		if not (character is Cultist):
			continue
		if not cultists.has(character):
			continue
		if victims.has(character):
			continue
		victims.append(character)
	return victims


func _remove_dragged_character(character: Character) -> void:
	cur_characters.erase(character)
	last_released_characters.erase(character)


func get_active_auto_persuader_count() -> int:
	var count := 0
	for cultist in cultists:
		if cultist and is_instance_valid(cultist) and cultist.has_auto_persuade_behavior():
			count += 1
	return count


func _is_outsider_targeted_by_other_cultist(outsider: Outsider, current_cultist: Cultist) -> bool:
	for cultist in cultists:
		if cultist == null or not is_instance_valid(cultist) or cultist == current_cultist:
			continue
		if cultist.auto_persuade_target == outsider:
			return true
	return false
