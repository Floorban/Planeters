class_name BuildingSlot
extends Node2D

@onready var window_sprite: Sprite2D = %WindowSprite
@onready var selectable_component: SelectableComponent = %SelectableComponent

@export var cur_building : Building


func _ready() -> void:
	selectable_component.hover_change.connect(_on_slot_hovered)


func _on_slot_hovered(hovered: bool) -> void:
	window_sprite.use_parent_material = not hovered
