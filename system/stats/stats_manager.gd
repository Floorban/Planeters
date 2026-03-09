class_name StatsManager
extends Control

signal stat_changed(stat: Stat, value: int)
signal stat_cost_failed(stat: Stat)

var stats : Dictionary = {}
@export var starting_stats : Array[StatChange]

var multipliers : Dictionary = {}

@export var stat_slots: Array[StatSlot]

func _ready() -> void:
	GameManager.stats_manager = self
	
	for slot in stat_slots:
		stat_changed.connect(slot._on_stat_changed)
		stat_cost_failed.connect(slot._pay_with_stat_failed)
		stats[slot.stat] = 0.0
		multipliers[slot.stat] = 1.0

	for s in starting_stats:
		add_stat(s.stat, s.amount)


func get_stat(stat: Stat) -> int:
	return stats.get(stat, 0.0)


func get_multiplier(stat: Stat) -> float:
	return multipliers.get(stat, 1.0)


func update_multiplier(stat: Stat, amount : float) -> void:
	multipliers[stat] += amount
	# update multiplier ui here
	# probably some stuff showing up when hovering the aciton buttons (e.g. how many ppl getting from next cult action )


func add_stat(stat: Stat, amount: float) -> void:
	if amount == 0.0:
		print("amount is 0")
		return
	# float in the system but ui shows int
	var final = amount * get_multiplier(stat)
	stats[stat] += final
	stat_changed.emit(stat, stats[stat])


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
