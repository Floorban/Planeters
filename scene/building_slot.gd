extends Area2D

@onready var window_sprite: Sprite2D = $WindowSprite

func _ready() -> void:
	mouse_entered.connect(_on_slot_hovered)
	mouse_exited.connect(_on_slot_unhovered)


func _on_slot_hovered() -> void:
	window_sprite.use_parent_material = false


func _on_slot_unhovered() -> void:
	window_sprite.use_parent_material = true
