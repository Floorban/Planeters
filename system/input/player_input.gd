extends Node

var enabled := true

var _mouse_delta := Vector2.ZERO
var _wheel_delta := 0.0
var mouse_sensitivity := 0.1
var wheel_sensitivity := 500.0

func _process(_delta):
	if not enabled:
		clear_frame_input()
		return

func _input(event):
	if not enabled:
		return
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_mouse_delta += event.relative * mouse_sensitivity
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			_wheel_delta -= wheel_sensitivity
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			_wheel_delta += wheel_sensitivity

func clear_mouse_input() -> void:
	_mouse_delta = Vector2.ZERO
	
func clear_wheel_input() -> void:
	_wheel_delta = 0.0

func clear_frame_input():
	clear_mouse_input()
	clear_wheel_input()

func get_mouse_delta() -> Vector2:
	return _mouse_delta

func get_wheel_delta() -> float:
	return _wheel_delta

func get_move_dir() -> Vector3:
	if not enabled:
		return Vector3.ZERO
	var v2 := Input.get_vector("left","right","up","down")
	return Vector3(v2.x, 0, v2.y).normalized()

#func is_interact_just_pressed() -> bool:
	#return enabled and Input.is_action_just_pressed("interact")
#
#func is_interact_just_released() -> bool:
	#return enabled and Input.is_action_just_released("interact")

func is_space_just_pressed() -> bool:
	return enabled and Input.is_action_just_pressed("space")

func is_space_pressing() -> bool:
	return enabled and Input.is_action_pressed("space")

func is_lmb_just_clicked() -> bool:
	return enabled and Input.is_action_just_pressed("left_click")

func is_lmb_clicking() -> bool:
	return enabled and Input.is_action_pressed("left_click")

func is_rmb_just_clicked() -> bool:
	return enabled and Input.is_action_just_pressed("right_click")

func is_rmb_just_released() -> bool:
	return enabled and Input.is_action_just_released("right_click")

func is_rmb_clicking() -> bool:
	return enabled and Input.is_action_pressed("right_click")
