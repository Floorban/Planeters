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
	cur_building.task_finished.connect(_on_task_finished)
	cur_building.is_being_dragged = false
	cur_building = null
	GameManager.building_shop.fade_in_out_component._close_panel()
	Audio.create_audio(SFXData.SOUND_EFFECT_TYPE.BUILD)


func discard_current_building() -> bool:
	if not cur_building:
		return false
	cur_building.queue_free()
	cur_building = null
	Audio.create_audio(SFXData.SOUND_EFFECT_TYPE.BTN_FAIL)
	return true


@export var recruit_task : Task
var task_scale_multipliers : Dictionary = {}
var cooldown_efficiency_by_type := {
	BuildingData.BuildingType.Recruit: 1.0,
	BuildingData.BuildingType.Sacrifice: 1.0,
	BuildingData.BuildingType.Build: 1.0,
}


func start_task(task : Task, building: Building) -> bool:
	if not building or not building.building_data:
		return false
	if building.building_data.building_type == BuildingData.BuildingType.Sacrifice:
		var dropped_character = GameManager.world_manager.get_dragged_character_for_drop()
		if not dropped_character:
			building.interact_failed()
			return false
		var sacrifice_amount := _get_sacrifice_member_cost(task)
		if not GameManager.world_manager.consume_characters_for_sacrifice(dropped_character, sacrifice_amount):
			building.interact_failed()
			return false
		_pay_modified(task, GameManager.sim_manager.member_stat)
		return true
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
	
	return true


func _can_pay_modified(task: Task) -> bool:
	for c in task.costs:
		if GameManager.stats_manager.get_stat(c.stat) < get_modified_cost(c, task):
			GameManager.stats_manager.stat_cost_failed.emit(c.stat)
			return false

	return true


func _pay_modified(task: Task, ignored_stat: Stat = null):
	for c in task.costs:
		if ignored_stat != null and c.stat == ignored_stat:
			continue
		GameManager.stats_manager.spend_stat(c.stat, get_modified_cost(c, task))
		if c.stat == GameManager.sim_manager.member_stat:
			Audio.create_audio(SFXData.SOUND_EFFECT_TYPE.SACRIFICE)


func _get_sacrifice_member_cost(task: Task) -> int:
	for c in task.costs:
		if c.stat == GameManager.sim_manager.member_stat:
			return max(1, int(round(get_modified_cost(c, task))))
	return 1


func get_modified_cost(change: StatChange, task: Task) -> float:
	var stat_mult = GameManager.stats_manager.get_cost_multiplier(change.stat)
	var task_scale = task_scale_multipliers.get(task, 1.0)
	return change.amount * stat_mult * task_scale


func get_modified_reward(change: StatChange, task: Task) -> float:
	var stat_mult = GameManager.stats_manager.get_reward_multiplier(change.stat)
	var task_scale = task_scale_multipliers.get(task, 1.0)
	return change.amount * stat_mult * task_scale


func modify_building_cooldown_efficiency(building_type: BuildingData.BuildingType, amount: float) -> void:
	cooldown_efficiency_by_type[building_type] = max(0.1, get_building_cooldown_efficiency(building_type) + amount)


func get_building_cooldown_efficiency(building_type: BuildingData.BuildingType) -> float:
	return cooldown_efficiency_by_type.get(building_type, 1.0)


func _on_task_finished(task : Task) -> void:
	# keep in mind that if upgrades are bought
	# when action is loading
	# the rewward would be updated with the new upgrades
	# even if the action starts before getting the upgrades
	if task == recruit_task:
		var outsider_amount := 1
		for reward in task.rewards:
			if reward.stat == GameManager.sim_manager.member_stat:
				outsider_amount = max(1, int(round(get_modified_reward(reward, task))))
				break
		GameManager.world_manager.spawn_outsider_wave(outsider_amount)
		return
	_apply_task_rewards(task)


func _apply_task_rewards(task: Task):
	for r in task.rewards:
		GameManager.stats_manager.add_stat(r.stat, get_modified_reward(r, task))
