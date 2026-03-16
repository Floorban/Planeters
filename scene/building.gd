class_name Building
extends Node2D

@onready var selectable_component: SelectableComponent = %SelectableComponent

func _ready() -> void:
	selectable_component.hover_change.connect(_on_hovered)


func _on_hovered(hovered: bool) -> void:
	if hovered:
		pass
	else:
		pass
