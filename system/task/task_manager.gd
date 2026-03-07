class_name TaskManager
extends Node

@export var task_btns: Array[TaskButton]
@export var task_slots : Array[TaskSlot]

@onready var task_cost_label: Label = %TaskCostLabel
@onready var task_effect_label: Label = %TaskEffectLabel

@export var max_parallel_tasks := 1


func _ready() -> void:
	for b in task_btns:
		b.show_task_info.connect(_show_task_info)
		b.hide_task_info.connect(func(): disable_task_info(true))
		b.start_task_request.connect(start_task)
	
	for s in task_slots:
		s.task_finished.connect(_on_task_finished)


func _show_task_info(task: Task) -> void:
	disable_task_info(false)
	task_cost_label.text = task.task_name
	task_effect_label.text = task.task_description


func disable_task_info(disable: bool) -> void:
	task_effect_label.visible = not disable
	task_cost_label.visible = not disable


func start_task(task : Task, btn: TaskButton) -> bool:
	if not GameManager.stats_manager.can_pay(task.costs):
		btn.button_press_failed()
		return false
		
	GameManager.stats_manager.pay_costs(task.costs)
	
	for slot in task_slots:
		if not slot.is_running:
			slot.start_task(task)
			_refresh_task_buttons()
			return true
	
	return false


func _on_task_finished(task : Task) -> void:
	# keep in mind that if upgrades are bought
	# when action is loading
	# the rewward would be updated with the new upgrades
	# even if the action starts before getting the upgrades
	GameManager.stats_manager.apply_rewards(task.rewards)
	_refresh_task_buttons()


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
