class_name BuildingManager
extends Node2D

const building_scene := preload("uid://cv4kkxyjh8pix")
var cur_building : Building

var placed_buildings: Array[Building]


func _ready() -> void:
	GameManager.building_manager = self


func _process(_delta: float) -> void:
	ghost_building_follow_mouse()


func ghost_building_follow_mouse() -> void:
	if not cur_building:
		return
	
	cur_building.global_position = get_global_mouse_position()


func get_new_building(building_data: BuildingData) -> void:
	#if cur_building:
		#push_error("already have a building in hand")
		#return
	
	var b := building_scene.instantiate() as Building
	add_child(b)
	cur_building = b
	cur_building.init_building(building_data)
	cur_building.is_being_dragged = true
	Audio.create_audio(SFXData.SOUND_EFFECT_TYPE.BTN_CONFIRM)


func place_building() -> void:
	if not cur_building:
		return
	
	cur_building.place_building()
	cur_building.start_task_request.connect(start_task)
	cur_building.task_finished.connect(_on_task_finished)
	cur_building.is_being_dragged = false
	cur_building = null
	Audio.create_audio(SFXData.SOUND_EFFECT_TYPE.BUILD)


@export var recruit_task : Task
var task_scale_multipliers : Dictionary = {}


func start_task(task : Task, building: Building) -> bool:
	# block recruit if church is full
	if task == recruit_task:
		var members = GameManager.stats_manager.get_stat(GameManager.sim_manager.member_stat)
		var reward_members = recruit_task.rewards[0].amount
		var church = GameManager.stats_manager.get_stat(GameManager.sim_manager.church_stat)
		var max_members = church * GameManager.sim_manager.members_per_church

		if members + reward_members >= max_members:
			building.interact_failed()
			GameManager.stats_manager.stat_cost_failed.emit(GameManager.sim_manager.member_stat)
			GameManager.stats_manager.stat_cost_failed.emit(GameManager.sim_manager.church_stat)
			return false
		
	if not _can_pay_modified(task):
		building.interact_failed()
		return false
		
	_pay_modified(task)
	
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
			Audio.create_audio(SFXData.SOUND_EFFECT_TYPE.SACRIFICE)


func get_modified_cost(change: StatChange, task: Task) -> float:
	var stat_mult = GameManager.stats_manager.get_cost_multiplier(change.stat)
	var task_scale = task_scale_multipliers.get(task, 1.0)
	return change.amount * stat_mult * task_scale


func get_modified_reward(change: StatChange, task: Task) -> float:
	var stat_mult = GameManager.stats_manager.get_reward_multiplier(change.stat)
	var task_scale = task_scale_multipliers.get(task, 1.0)
	return change.amount * stat_mult * task_scale


func _on_task_finished(task : Task) -> void:
	# keep in mind that if upgrades are bought
	# when action is loading
	# the rewward would be updated with the new upgrades
	# even if the action starts before getting the upgrades
	_apply_task_rewards(task)


func _apply_task_rewards(task: Task):
	for r in task.rewards:
		GameManager.stats_manager.add_stat(r.stat, get_modified_reward(r, task))
