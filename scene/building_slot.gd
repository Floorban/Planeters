class_name BuildingSlot
extends Node2D

@onready var window_sprite: Sprite2D = %WindowSprite
@onready var selectable_component: SelectableComponent = %SelectableComponent

var building_to_be_placed : Building
@export var my_building : Building


func _ready() -> void:
	selectable_component.hover_change.connect(_on_slot_hovered)
	selectable_component.select.connect(_on_slot_selected)
	selectable_component.right_select.connect(_on_remove_building)


func _on_slot_hovered(hovered: bool) -> void:
	if not GameManager.building_manager.cur_building or my_building:
		return
	window_sprite.use_parent_material = not hovered
	building_to_be_placed = GameManager.building_manager.cur_building if hovered else null


func _on_slot_selected(_selected: bool) -> void:
	if building_to_be_placed:
		# buidling placement here
		my_building = GameManager.building_manager.cur_building
		GameManager.building_manager.place_building()
		building_to_be_placed = null
		my_building.global_position = global_position
		window_sprite.use_parent_material = true
	elif my_building and GameManager.building_manager.cur_building == null and not building_to_be_placed:
		# interact with the building here
		my_building.interact_with_building()


func _on_remove_building() -> void:
	if my_building and GameManager.building_manager.cur_building == null and not building_to_be_placed:
		GameManager.building_manager.get_new_building(my_building.building_data)
		# since on slot hovered is not runned, manually set it here so player can click again to place at the slot again
		# without moving mouse oout and in
		building_to_be_placed = my_building
		my_building.queue_free()
		my_building = null
		window_sprite.use_parent_material = false
