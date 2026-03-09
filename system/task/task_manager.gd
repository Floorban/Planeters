class_name TaskManager
extends Node

@export var task_btns: Array[TaskButton]
@export var task_slots : Array[TaskSlot]

@onready var task_cost_label: RichTextLabel = %TaskCostLabel
@onready var task_effect_label: RichTextLabel = %TaskEffectLabel

@export var max_parallel_tasks := 1


func _ready() -> void:
	GameManager.task_manager = self
	for b in task_btns:
		b.show_task_info.connect(_show_task_info)
		b.hide_task_info.connect(_hide_task_info)
		b.start_task_request.connect(start_task)
	
	for s in task_slots:
		s.task_finished.connect(_on_task_finished)


func _show_task_info(task: Task) -> void:
	_hide_task_info()
	for c in task.costs:
		task_cost_label.append_text(c.to_rich_text(true) + "\n")
	for r in task.rewards:
		task_effect_label.append_text(r.to_rich_text(false) + "\n")


func _hide_task_info() -> void:
	task_cost_label.clear()
	task_effect_label.clear()


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
