class_name Building
extends Node2D

var building_data: BuildingData
@onready var building_sprite: AnimatedSprite2D = %BuildingSprite
@onready var selectable_component: SelectableComponent = %SelectableComponent

var is_being_dragged := false
var is_hovered := false


func _ready() -> void:
	selectable_component.hover_change.connect(_on_hovered)


func _on_hovered(hovered: bool) -> void:
	if is_being_dragged:
		return
	is_hovered = hovered
	building_sprite.use_parent_material = not is_hovered


func init_building(data: BuildingData) -> void:
	building_data = data
	building_sprite.sprite_frames = data.texture_frames


func place_building() -> void:
	is_being_dragged = false
	is_hovered = true
	building_sprite.use_parent_material = not is_hovered


func interact_with_building() -> void:
	print("interacting with "+ name)
	Audio.create_audio(SFXData.SOUND_EFFECT_TYPE.UPGRADE_PURCHASE)
