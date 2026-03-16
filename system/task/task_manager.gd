class_name TaskManager
extends Control

signal update_task()

@export var task_btns: Array[TaskButton]
@export var task_slots : Array[TaskSlot]

@export var recruit_task : Task

@onready var task_cost_label: RichTextLabel = %TaskCostLabel
@onready var task_effect_label: RichTextLabel = %TaskEffectLabel
@onready var task_duration_label: RichTextLabel = %TaskDurationLabel
@onready var max_action_label: Label = %MaxActionLabel

@export var max_parallel_tasks := 1:
	set(value):
		max_parallel_tasks = value
		if is_node_ready(): 
			max_action_label.text = "Max Actions: " + str(max_parallel_tasks)
			_refresh_task_buttons()

var global_duration_multiplier := 1.0
var duration_multipliers : Dictionary = {} # Task -> float


func _ready() -> void:
	GameManager.task_manager = self
	for b in task_btns:
		b.show_task_info.connect(_show_task_info)
		b.hide_task_info.connect(_hide_task_info)
		b.start_task_request.connect(start_task)
		duration_multipliers[b.task] = 1.0
	
	for s in task_slots:
		s.task_finished.connect(_on_task_finished)


func _show_task_info(task: Task) -> void:
	_hide_task_info()
	for c in task.costs:
		task_cost_label.append_text(c.to_rich_text(get_modified_cost(c, task), true) + "\n")
		if (get_modified_cost(c, task) <= 0.0):
			push_error("cost is below 0 error")
	for r in task.rewards:
		task_effect_label.append_text(r.to_rich_text(get_modified_reward(r, task), false) + "\n")
	task_duration_label.append_text("Duration: " + str(task.duration * get_duration_multiplier(task)))


func _hide_task_info() -> void:
	task_cost_label.clear()
	task_effect_label.clear()
	task_duration_label.clear()


func start_task(task : Task, btn: TaskButton) -> bool:
	# block recruit if church is full
	if task == recruit_task:
		var members = GameManager.stats_manager.get_stat(GameManager.sim_manager.member_stat)
		var reward_members = recruit_task.rewards[0].amount
		var church = GameManager.stats_manager.get_stat(GameManager.sim_manager.church_stat)
		var max_members = church * GameManager.sim_manager.members_per_church

		if members + reward_members >= max_members:
			btn.button_press_failed()
			GameManager.stats_manager.stat_cost_failed.emit(GameManager.sim_manager.member_stat)
			GameManager.stats_manager.stat_cost_failed.emit(GameManager.sim_manager.church_stat)
			return false
		
	if not _can_pay_modified(task):
		btn.button_press_failed()
		return false
		
	_pay_modified(task)
	
	for slot in task_slots:
		if not slot.is_running:
			slot.start_task(task)
			_refresh_task_buttons()
			return true
	
	return false


func _can_pay_modified(task: Task) -> bool:
	for c in task.costs:
		if GameManager.stats_manager.get_stat(c.stat) < get_modified_cost(c, task):
			GameManager.stats_manager.stat_cost_failed.emit(c.stat)
			return false

	return true


func _pay_modified(task: Task):
	for c in task.costs:
		GameManager.stats_manager.spend_stat(c.stat, get_modified_cost(c, task))
		if c.stat == GameManager.sim_manager.member_stat:
			Sound.fx("res://asset/sound/fx/f_sacrifice.ogg")


func _on_task_finished(task : Task) -> void:
	# keep in mind that if upgrades are bought
	# when action is loading
	# the rewward would be updated with the new upgrades
	# even if the action starts before getting the upgrades
	_apply_task_rewards(task)
	_refresh_task_buttons()
	update_task.emit()


func _apply_task_rewards(task: Task):
	for r in task.rewards:
		GameManager.stats_manager.add_stat(r.stat, get_modified_reward(r, task))


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


func get_duration_multiplier(task: Task) -> float:
	return duration_multipliers.get(task, 1.0) * global_duration_multiplier


func modify_duration(task: Task, amount: float):
	duration_multipliers[task] += amount
	if duration_multipliers[task] <= 0.05:
		push_error("task duration too short")
		duration_multipliers[task] = 0.05


func add_task_capacity(amount: int) -> void:
	max_parallel_tasks += amount
	_refresh_task_buttons()


func get_soul_gain_per_sacrifice() -> float:
	for b in task_btns:
		if b.task.task_name == "Sacrifice":
			for r in b.task.rewards:
				if r.stat == GameManager.sim_manager.soul_stat:
					return r.amount
	return 0.0

var task_scale_multipliers : Dictionary = {}

func get_modified_cost(change: StatChange, task: Task) -> float:
	var stat_mult = GameManager.stats_manager.get_cost_multiplier(change.stat)
	var task_scale = task_scale_multipliers.get(task, 1.0)
	return change.amount * stat_mult * task_scale


func get_modified_reward(change: StatChange, task: Task) -> float:
	var stat_mult = GameManager.stats_manager.get_reward_multiplier(change.stat)
	var task_scale = task_scale_multipliers.get(task, 1.0)
	return change.amount * stat_mult * task_scale
