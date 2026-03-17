class_name Building
extends Node2D

var building_data: BuildingData
@onready var building_sprite: AnimatedSprite2D = %BuildingSprite
@onready var sprite_material : ShaderMaterial = building_sprite.material

var is_being_dragged := false
var is_hovered := false


func _ready() -> void:
	if building_sprite and sprite_material:
		building_sprite.material = sprite_material.duplicate()
		sprite_material = building_sprite.material


func on_hovered(hovered: bool) -> void:
	if is_being_dragged:
		return
	is_hovered = hovered
	sprite_material.set_shader_parameter("outline_mode", 1) if hovered else sprite_material.set_shader_parameter("outline_mode", 0)


func init_building(data: BuildingData) -> void:
	building_data = data
	building_sprite.sprite_frames = data.texture_frames
	sprite_material.set_shader_parameter("enable_shadow", true)


func place_building() -> void:
	is_being_dragged = false
	is_hovered = true
	sprite_material.set_shader_parameter("outline_mode", 1)
	sprite_material.set_shader_parameter("enable_shadow", false)


func interact_with_building() -> void:
	print("interacting with "+ name)
	Audio.create_audio(SFXData.SOUND_EFFECT_TYPE.UPGRADE_PURCHASE)
