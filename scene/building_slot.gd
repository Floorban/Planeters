class_name BuildingSlot
extends Node2D

@onready var window_sprite: Sprite2D = %WindowSprite
@onready var sprite_material : ShaderMaterial = window_sprite.material
@onready var selectable_component: SelectableComponent = %SelectableComponent

@export var my_building : Building

var cooldown_timer := 0.0
var cooldown_duration := 5.0
var is_on_cooldown := false
var slot_efficiency_multiplier := 1.0 
var is_locked := false


func _ready() -> void:
	selectable_component.hover_change.connect(_on_slot_hovered)
	selectable_component.select.connect(_on_slot_selected)
	selectable_component.deselect.connect(_on_slot_received)
	selectable_component.right_select.connect(
	func():
		_on_remove_building(my_building)
		my_building = null
	)
	if window_sprite and sprite_material:
		window_sprite.material = sprite_material.duplicate()
		sprite_material = window_sprite.material


func _process(delta: float) -> void:
	if is_on_cooldown and my_building:
		cooldown_timer += delta
		var total_time_needed = cooldown_duration / get_cooldown_speed_multiplier()
		var progress_percent = clamp(cooldown_timer / total_time_needed, 0.0, 1.0)
		my_building.set_cooldown_visuals(progress_percent, true)
		if cooldown_timer >= total_time_needed:
			_finish_cooldown()


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
	GameManager.building_manager.get_new_building(building_to_remove.building_data)
	building_to_remove.queue_free()
	is_on_cooldown = false
	sprite_material.set_shader_parameter("outline_mode", 1)


func _switch_building(current_building: Building, held_building: Building):
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
			print("building is still cooling down...")


func _on_slot_received() -> void:
	if is_locked:
		return
	if not my_building or my_building.building_data.building_type != BuildingData.BuildingType.Sacrifice:
		return
	var dropped_character = GameManager.world_manager.get_dragged_character_for_drop()
	if not dropped_character:
		return
	var held_building = GameManager.building_manager.cur_building
	if my_building and not held_building:
		if not is_on_cooldown:
			_start_interaction()
		else:
			print("building is still cooling down...")


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
	
	
