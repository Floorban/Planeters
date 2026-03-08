class_name StatSlot
extends Control

@onready var stats_manager = get_parent() as StatsManager

@export var stat : Stat
@onready var stat_icon: TextureRect = $StatIcon
@onready var stat_num_label: Label = $StatNumLabel

var target_value : float = 0.0
var displayed_value : float = 0.0

var flash_tween : Tween
var punch_tween : Tween


func _ready() -> void:
	if stat:
		stat_icon.texture = stat.stat_icon
		stat_num_label.modulate = stat.stat_color
	if stats_manager:
		stats_manager.stat_changed.connect(_on_stat_changed)
		stats_manager.stat_cost_failed.connect(_pay_with_stat_failed)


func _process(delta):
	var diff := target_value - displayed_value
	var speed := clampf(abs(diff) * 5, 5, 40)

	displayed_value += diff * delta * speed

	if abs(diff) < 0.5:
		displayed_value = target_value
	
	# UI shows int but system uses float
	var new_value := int(displayed_value)
	if stat_num_label.text != str(new_value):
		stat_num_label.text = str(new_value)


func _on_stat_changed(changed_stat: Stat, value: float) -> void:
	if changed_stat != stat:
		return

	var previous_target = target_value
	target_value = value

	if target_value > previous_target:
		_flash_text_with_color(Color(0.542, 1.05, 0.359, 1.0))
		_finish_value_animation()


func _pay_with_stat_failed(changed_stat: Stat) -> void:
	if changed_stat != stat:
		return
	_flash_text_with_color(Color(0.796, 0.0, 0.0, 1.0))


func _finish_value_animation():
	if punch_tween:
		punch_tween.kill()
	stat_num_label.scale = Vector2.ONE
	punch_tween = create_tween().set_ease(Tween.EASE_OUT)
	punch_tween.tween_property(stat_num_label, "scale", Vector2(1.25, 1.25), 0.08)
	punch_tween.tween_property(stat_num_label, "scale", Vector2.ONE, 0.12)


func _flash_text_with_color(color: Color):
	var og_color = stat.stat_color
	stat_num_label.modulate = og_color
	if flash_tween:
		flash_tween.kill()
	flash_tween = create_tween().set_ease(Tween.EASE_OUT)
	flash_tween.tween_property(stat_num_label, "modulate", color, 0.12)
	flash_tween.tween_property(stat_num_label, "modulate", og_color, 0.2)
	flash_tween.tween_callback(func(): stat_num_label.modulate = og_color)
