class_name TaskManager
extends Node

@export var task_btns: Array[TaskButton]
@export var task_slots : Array[TaskProgress]

@export var max_parallel_tasks := 1


func _ready() -> void:
	for b in task_btns:
		b.start_task_request.connect(start_task)
	
	for s in task_slots:
		s.task_finished.connect(_on_task_finished)


func start_task(task : Task) -> bool:
	for slot in task_slots:
		if not slot.is_running:
			slot.start_task(task)
			_refresh_task_buttons()
			return true
	
	return false


func _on_task_finished(task : Task) -> void:
	_refresh_task_buttons()
	print(task.task_name)


func _refresh_task_buttons() -> void:
	var running := 0
	for slot in task_slots:
		if slot.is_running:
			running += 1
	
	var should_disable := running >= max_parallel_tasks
	
	for b in task_btns:
		b.disabled = should_disable
		if not should_disable:
			b.button_pressed = false
