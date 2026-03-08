class_name SimulationManager
extends Node

@export var member_stat : Stat
@export var coin_stat : Stat
@export var loyalty_stat : Stat
@export var church_stat : Stat

@export var member_coin_gain := 5.0
@export var member_recruit_gain := 1.0

@export var coin_interval := 2.0
@export var recruit_interval := 5.0

var coin_timer := 0.0
var recruit_timer := 0.0

@export var members_per_church := 10


func _process(delta) -> void:
	if GameManager.is_paused:
		return
	
	coin_timer = _process_timer(coin_timer, coin_interval, delta, _tick.bind(coin_stat, member_coin_gain))
	if not _has_church_cap():
		recruit_timer = _process_timer(recruit_timer, recruit_interval, delta, _tick.bind(member_stat, member_recruit_gain))


func _process_timer(timer: float, interval: float, delta: float, tick: Callable) -> float:
	timer += delta
	
	while  timer >= interval:
		tick.call()
		timer -= interval
	
	return timer


func _tick(stat: Stat, per_gain: float) -> void:
	var members = GameManager.stats_manager.get_stat(member_stat)
	GameManager.stats_manager.add_stat(stat, members * per_gain)


func _calculate_loyalty_efficiency(loyalty: float) -> float:
	return 1.0 + loyalty * 0.02


func _has_church_cap() -> bool:
	var members = GameManager.stats_manager.get_stat(member_stat)
	var church = GameManager.stats_manager.get_stat(church_stat)
	var max_members = church * members_per_church
	if members > max_members:
		GameManager.stats_manager.set_stat(member_stat, max_members)
		GameManager.stats_manager.stat_cost_failed.emit(church_stat)
		return true
	
	return false
