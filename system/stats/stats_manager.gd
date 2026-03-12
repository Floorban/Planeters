class_name StatsManager
extends Control

signal stat_changed(stat: Stat, value: int)
signal stat_cost_failed(stat: Stat)

var stats : Dictionary = {}
@export var starting_stats : Array[StatChange]

var multipliers : Dictionary = {}
var reward_multipliers : Dictionary = {}
var cost_multipliers : Dictionary = {}

@export var stat_slots: Array[StatSlot]


func _ready() -> void:
	GameManager.stats_manager = self
	
	for slot in stat_slots:
		stat_changed.connect(slot._on_stat_changed)
		stat_cost_failed.connect(slot._pay_with_stat_failed)
		stats[slot.stat] = 0.0
		multipliers[slot.stat] = 1.0
		reward_multipliers[slot.stat] = 1.0
		cost_multipliers[slot.stat] = 1.0

	for s in starting_stats:
		add_stat(s.stat, s.amount)
	
	GameManager.overview.reset_overview_labels()


func get_stat(stat: Stat) -> int:
	return stats.get(stat, 0.0)


func get_multiplier(stat: Stat) -> float:
	return multipliers.get(stat, 1.0)


func get_reward_multiplier(stat: Stat) -> float:
	return reward_multipliers.get(stat, 1.0)


func get_cost_multiplier(stat: Stat) -> float:
	return cost_multipliers.get(stat, 1.0)


func update_multiplier(stat: Stat, amount : float) -> void:
	multipliers[stat] += amount
	

func modify_reward(stat: Stat, amount: float):
	reward_multipliers[stat] += amount


func modify_cost(stat: Stat, amount: float):
	cost_multipliers[stat] += amount


func add_stat(stat: Stat, amount: float) -> void:
	if amount < 1.0:
		return
	if not stats.has(stat):
		GameManager.game_over()
		return
	# float in the system but ui shows int
	stats[stat] += amount
	stat_changed.emit(stat, stats[stat])
	if stat == GameManager.sim_manager.member_stat:
		GameManager.overview.set_member_label(int(amount))
		Audio.create_audio(SFXData.SOUND_EFFECT_TYPE.GET_MEMBER)
	if stat == GameManager.sim_manager.coin_stat:
		GameManager.overview.set_revenue_label(int(amount))
		Audio.create_audio(SFXData.SOUND_EFFECT_TYPE.COIN)
	if stat == GameManager.sim_manager.soul_stat:
		GameManager.overview.set_soul_label(int(amount))
		Audio.create_audio(SFXData.SOUND_EFFECT_TYPE.SOUL)
	if stat == GameManager.sim_manager.church_stat:
		Audio.create_audio(SFXData.SOUND_EFFECT_TYPE.BUILD)


# for capping cult member from church num
func set_stat(stat: Stat, value: float) -> void:
	stats[stat] = value
	stat_changed.emit(stat, stats[stat])
	stat_cost_failed.emit(stat)


func spend_stat(stat: Stat, amount: float) -> bool:
	if stats[stat] < amount:
		return false
	
	stats[stat] -= amount
	stat_changed.emit(stat, stats[stat])
	return true


func apply_rewards(rewards: Array[StatChange]) -> void:
	for r in rewards:
		add_stat(r.stat, r.amount)


func can_pay(costs: Array[StatChange]) -> bool:
	for c in costs:
		if get_stat(c.stat) < c.amount:
			stat_cost_failed.emit(c.stat)
			return false
	return true


func pay_costs(costs : Array[StatChange]) -> void:
	for c in costs:
		spend_stat(c.stat, c.amount)
