class_name Building
extends Node2D

var building_data: BuildingData
@onready var building_sprite: AnimatedSprite2D = %BuildingSprite
@onready var selectable_component: SelectableComponent = %SelectableComponent


func _ready() -> void:
	selectable_component.hover_change.connect(_on_hovered)


func _on_hovered(hovered: bool) -> void:
	if hovered:
		pass
	else:
		pass


func init_building(data: BuildingData) -> void:
	building_data = data
	building_sprite.sprite_frames = data.texture_frames
