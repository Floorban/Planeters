extends Node3D
class_name CameraController

var _offset: Vector3

@export var _default__offset : Vector3
var _default_zoom : float

@onready var spring_arm: SpringArm3D = %SpringArm3D
@onready var spring_position: Marker3D = %SpringPosition
var can_control := true
var rotating := false
var focusing := false

@export_category("Zoom Settings")
@export var arm_length_min := -3.0
@export var arm_length_max := 17.0
@export var zoom_smooth_speed: float = 5.0
var _target_zoom: float

func _ready() -> void:
	_target_zoom = spring_arm.spring_length
	_default_zoom = _target_zoom
	top_level = true

func _process(delta: float) -> void:
	if not can_control: 
		return

	rotating = PlayerInput.is_rmb_clicking()
	if rotating:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	var mouse_delta := PlayerInput.get_mouse_delta()
	if mouse_delta != Vector2.ZERO and rotating:
		Planet.rotate_y(mouse_delta.x * delta)
		Planet.rotate_z(-mouse_delta.y * delta)
	PlayerInput.clear_mouse_input()
	
	var zoom_delta := PlayerInput.get_wheel_delta()
	if zoom_delta != 0 and not focusing and not GameManager.building_manager.placing:
		_target_zoom += zoom_delta * delta
	_target_zoom = clamp(_target_zoom, arm_length_min, arm_length_max)
	spring_arm.spring_length = lerp(spring_arm.spring_length, _target_zoom, delta * zoom_smooth_speed)
	PlayerInput.clear_wheel_input()

func focus_at(focus__offset: Vector3, focus_zoom: float = 2.0) -> void:
	focusing = true
	_offset = focus__offset
	_target_zoom = focus_zoom

func exit_focus_mode() -> void:
	focusing = true
	_offset = _default__offset
	_target_zoom = _default_zoom
	
