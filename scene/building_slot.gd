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


func _ready() -> void:
	selectable_component.hover_change.connect(_on_slot_hovered)
	selectable_component.select.connect(_on_slot_selected)
	selectable_component.right_select.connect(_on_remove_building)
	if window_sprite and sprite_material:
		window_sprite.material = sprite_material.duplicate()
		sprite_material = window_sprite.material


func _process(delta: float) -> void:
	if is_on_cooldown and my_building:
		cooldown_timer += delta
		
		# Calculate progress (0.0 to 1.0)
		# Note: We divide by efficiency. Higher efficiency = faster progress.
		var total_time_needed = cooldown_duration / slot_efficiency_multiplier
		var progress_percent = clamp(cooldown_timer / total_time_needed, 0.0, 1.0)
		
		# Tell building to update its shader
		my_building.set_cooldown_visuals(progress_percent, true)
		
		if cooldown_timer >= total_time_needed:
			_finish_cooldown()


func _finish_cooldown() -> void:
	is_on_cooldown = false
	cooldown_timer = 0.0
	if my_building:
		my_building.finish_buildling_cooldown()


func _start_interaction() -> void:
	my_building.interact_with_building()
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


func _on_remove_building() -> void:
	if my_building and GameManager.building_manager.cur_building == null:
		GameManager.building_manager.get_new_building(my_building.building_data)
		my_building.queue_free()
		my_building = null
		is_on_cooldown = false
		sprite_material.set_shader_parameter("outline_mode", 1)


func _on_slot_hovered(hovered: bool) -> void:
	if my_building:
		my_building.on_hovered(hovered)
		my_building.set_cooldown_visuals(cooldown_timer / (cooldown_duration / slot_efficiency_multiplier), is_on_cooldown)
		return
	if not GameManager.building_manager.cur_building:
		return
	sprite_material.set_shader_parameter("outline_mode", 1) if hovered else sprite_material.set_shader_parameter("outline_mode", 0)


func _on_slot_selected(_selected: bool) -> void:
	var held_building = GameManager.building_manager.cur_building
	if selectable_component.is_hovered and held_building:
		# buidling placement here
		my_building = held_building
		GameManager.building_manager.place_building()
		my_building.global_position = global_position
		sprite_material.set_shader_parameter("outline_mode", 0)
	elif my_building  and not held_building:
		if not is_on_cooldown:
			_start_interaction()
		else:
			print("building is still cooling down...")
		
