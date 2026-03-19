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
@export var max_max_visible_cultists := 500
var max_visible_cultists := 0
var current_members := 0

var cur_character : Character
var last_released_character : Character
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
	return square_center.global_position + Vector2(randf_range(-230, 240),randf_range(-40, 150))


func get_dragged_character_for_drop() -> Character:
	if cur_character:
		return cur_character
	return last_released_character


func consume_selected_character_for_sacrifice(character: Character) -> bool:
	return consume_characters_for_sacrifice(character, 1)


func consume_characters_for_sacrifice(character: Character, amount: int) -> bool:
	if amount <= 0:
		return false
	if not character or not is_instance_valid(character):
		return false
	if not cultists.has(character):
		return false
	if cultists.size() < amount:
		return false
	var victims: Array[Character] = [character]
	while victims.size() < amount:
		var candidate : Cultist = cultists.pick_random()
		if victims.has(candidate):
			continue
		victims.append(candidate)
	for victim in victims:
		cultists.erase(victim)
		if cur_character == victim:
			cur_character = null
		if last_released_character == victim:
			last_released_character = null
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
	if last_released_character == character and character.state != Character.CharacterState.BEING_KILLED:
		last_released_character = null


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
		cur_character = cultist
	)
	cultist.deselected.connect(func():
		if cur_character and cur_character == cultist:
			cur_character = null
		last_released_character = cultist
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
