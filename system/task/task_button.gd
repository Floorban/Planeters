class_name TaskButton
extends Button

signal show_task_info(task: Task)
signal hide_task_info()
signal start_task_request(task: Task, button: TaskButton)

@export var task: Task

var flash_tween : Tween


func _ready() -> void:
	mouse_entered.connect(_on_mouse_enter)
	mouse_exited.connect(_on_mouse_exited)
	toggled.connect(_on_task_btn_toggled)
	
	if task:
		text = task.task_name


func _on_mouse_enter() -> void:
	show_task_info.emit(task)


func _on_mouse_exited() -> void:
	hide_task_info.emit()


func _on_task_btn_toggled(toggled_on : bool) -> void:
	if toggled_on:
		start_task_request.emit(task, self)
		Sound.fx("res://asset/sound/fx/f_confirm.ogg")


func button_press_failed() -> void:
	Sound.fx("res://asset/sound/fx/f_locked.ogg")
	button_pressed = false
	var og_color = Color.WHITE
	modulate = og_color
	
	if flash_tween:
		flash_tween.kill()
	flash_tween = create_tween()
	flash_tween.tween_property(self, "modulate", Color(0.796, 0.0, 0.0, 1.0), 0.08)
	flash_tween.tween_property(self, "modulate", og_color, 0.1)
	flash_tween.tween_callback(func(): modulate = og_color)


func disable_button(disable : bool) -> void:
	disabled = disable
	if not disabled:
		button_pressed = disabled
