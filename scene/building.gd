class_name Building
extends Node2D

const CAN_INTERACT_COLOR := Color(0.323, 0.716, 0.189, 1.0)
const CANNOT_INTERACT_COLOR := Color(0.757, 0.0, 0.0, 1.0)
const INTERACT_COLOR := Color(1.0, 1.0, 1.0, 1.0)

signal start_task_request(task: Task, building: Building)
signal task_finished(task : Task)

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
	var mode = 1 if is_hovered else 0
	sprite_material.set_shader_parameter("outline_mode", mode)


func set_cooldown_visuals(progress_value: float, on_cooldown: bool) -> void:
	if on_cooldown:
		sprite_material.set_shader_parameter("outline_mode", 2)
		sprite_material.set_shader_parameter("progress", progress_value)
		sprite_material.set_shader_parameter("outline_color", CANNOT_INTERACT_COLOR)
	else:
		# if hovered show white outline
		var outline_color := INTERACT_COLOR if is_hovered else CAN_INTERACT_COLOR
		sprite_material.set_shader_parameter("outline_mode", 1)
		sprite_material.set_shader_parameter("outline_color", outline_color)


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
	start_task_request.emit(building_data.task, self)
	Audio.create_audio(SFXData.SOUND_EFFECT_TYPE.UPGRADE_PURCHASE)
	building_sprite.play("interact")

var flash_tween : Tween

func interact_failed() -> void:
	Audio.create_audio(SFXData.SOUND_EFFECT_TYPE.BTN_FAIL)
	var og_color = Color.WHITE
	modulate = og_color
	
	if flash_tween:
		flash_tween.kill()
	flash_tween = create_tween()
	flash_tween.tween_property(self, "modulate", Color(0.796, 0.0, 0.0, 1.0), 0.08)
	flash_tween.tween_property(self, "modulate", og_color, 0.1)
	flash_tween.tween_callback(func(): modulate = og_color)


func finish_buildling_cooldown() -> void:
	set_cooldown_visuals(1.0, false)
	task_finished.emit(building_data.task)
