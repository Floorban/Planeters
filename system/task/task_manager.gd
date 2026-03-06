class_name TaskManager
extends Node

@export var task_btns: Array[TaskButton]
@export var task_slots : Array[TaskSlot]

@export var max_parallel_tasks := 1


func _ready() -> void:
	for b in task_btns:
		b.start_task_request.connect(start_task)
	
	for s in task_slots:
		s.task_finished.connect(_on_task_finished)


func start_task(task : Task, btn: TaskButton) -> bool:
	if not GameManager.stats_manager.can_pay(task.costs):
		print("Not enough resources")
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
