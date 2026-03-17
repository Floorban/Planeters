class_name BuildingSlot
extends Node2D

@onready var window_sprite: Sprite2D = %WindowSprite
@onready var sprite_material : ShaderMaterial = window_sprite.material
@onready var selectable_component: SelectableComponent = %SelectableComponent

@export var my_building : Building


func _ready() -> void:
	selectable_component.hover_change.connect(_on_slot_hovered)
	selectable_component.select.connect(_on_slot_selected)
	selectable_component.right_select.connect(_on_remove_building)
	if window_sprite and sprite_material:
		window_sprite.material = sprite_material.duplicate()
		sprite_material = window_sprite.material


func _on_slot_hovered(hovered: bool) -> void:
	if my_building:
		my_building.on_hovered(hovered)
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
		# interact with the building here
		my_building.interact_with_building()


func _on_remove_building() -> void:
	if my_building and GameManager.building_manager.cur_building == null:
		GameManager.building_manager.get_new_building(my_building.building_data)
		# since on slot hovered is not runned, manually set it here so player can click again to place at the slot again
		# without moving mouse oout and in
		my_building.queue_free()
		my_building = null
		sprite_material.set_shader_parameter("outline_mode", 1)
