class_name StatsManager
extends Control

var stats : Dictionary = {}
@export var stat_slots : Array[StatSlot]


func _ready() -> void:
	GameManager.stats_manager = self
	for slot in stat_slots:
		stats[slot.stat] = 0


func get_stats(task: Task) -> void:
	for reward in task.rewards:
		stats[reward.stat] += reward.amount
		_update_stat_ui(reward.stat)


func _update_stat_ui(stat: Stat) -> void:
	for slot in stat_slots:
		if slot.stat == stat:
			slot.set_value(stats[stat])
