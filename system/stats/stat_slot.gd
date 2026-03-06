class_name StatSlot
extends Control

@export var stat : Stat
@onready var stat_icon: TextureRect = $StatIcon
@onready var stat_num_label: Label = $StatNumLabel


func _ready() -> void:
	if stat == null:
		return
	stat_icon.texture = stat.stat_icon
	set_value(0)


func set_value(value:int) -> void:
	stat_num_label.text = str(value)
