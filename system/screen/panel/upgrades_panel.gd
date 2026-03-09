class_name UpgradesPanel
extends Control

@onready var upgrades_holder: Control = $UpgradesHolder

@export var can_drag := false
var dragging := false
var last_mouse_pos := Vector2.ZERO

@export var zoom_speed := 0.05
@export var min_zoom := 0.3
@export var max_zoom := 1.5


func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	clip_contents = true
	upgrades_holder.pivot_offset = upgrades_holder.size / 2
	upgrades_holder.position = (size / 2) - (upgrades_holder.size / 2)


func _on_mouse_entered() -> void:
	can_drag = true


func _on_mouse_exited() -> void:
	can_drag = false


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT or event.button_index == MOUSE_BUTTON_MIDDLE:
			dragging = event.pressed
			accept_event() 


func _input(event) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT or event.button_index == MOUSE_BUTTON_MIDDLE:
			dragging = event.pressed
		
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_set_zoom(upgrades_holder.scale + Vector2(zoom_speed, zoom_speed))
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_set_zoom(upgrades_holder.scale - Vector2(zoom_speed, zoom_speed))

	if event is InputEventMouseMotion and dragging and can_drag:
		upgrades_holder.position += event.relative
		_clamp_position()


func _set_zoom(new_scale: Vector2) -> void:
	new_scale.x = clamp(new_scale.x, min_zoom, max_zoom)
	new_scale.y = clamp(new_scale.y, min_zoom, max_zoom)
	upgrades_holder.scale = new_scale
	_clamp_position()

func _clamp_position() -> void:
	var scaled_size = upgrades_holder.size * upgrades_holder.scale
	var pivot_correction = (scaled_size - upgrades_holder.size) / 2.0
	
	var margin = 100.0 
	var min_x = -scaled_size.x + margin + pivot_correction.x
	var max_x = size.x - margin + pivot_correction.x
	var min_y = -scaled_size.y + margin + pivot_correction.y
	var max_y = size.y - margin * 2 + pivot_correction.y
	upgrades_holder.position.x = clamp(upgrades_holder.position.x, min_x, max_x)
	upgrades_holder.position.y = clamp(upgrades_holder.position.y, min_y, max_y)
