class_name StatsManager
extends Control

signal stat_changed(stat: Stat, value: int)

var stats : Dictionary = {}
@export var starting_stats : Array[StatChange]

var multipliers : Dictionary = {}


func _ready() -> void:
	GameManager.stats_manager = self
	for s in starting_stats:
		stats[s.stat] = 0
		add_stat(s.stat, s.amount)
		multipliers[s.stat] = 1.0


func get_stat(stat: Stat) -> int:
	return stats.get(stat, 0)


func get_multiplier(stat: Stat) -> float:
	return multipliers.get(stat, 1.0)


func update_multiplier(stat: Stat, amount : float) -> void:
	multipliers[stat] += amount
	# update multiplier ui here
	# probably some stuff showing up when hovering the aciton buttons (e.g. how many ppl getting from next cult action )

func add_stat(stat: Stat, amount: int) -> void:
	#stats[stat] += amount
	# int or float here? check again later
	var final = int(amount * get_multiplier(stat))
	stats[stat] += final
	
	stat_changed.emit(stat, stats[stat])


func spend_stat(stat: Stat, amount: int) -> bool:
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
			return false
	return true


func pay_costs(costs : Array[StatChange]) -> void:
	for c in costs:
		spend_stat(c.stat, c.amount)
