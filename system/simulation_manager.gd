class_name SimulationManager
extends Node

@export var member_stat : Stat
@export var church_stat : Stat
@export var coin_stat : Stat
@export var soul_stat : Stat
@export var loyalty_stat : Stat

@export var member_recruit_gain := 0.1
@export var member_coin_gain := 1.0

@export var recruit_interval := 10.0
@export var coin_interval := 5.0

var coin_timer := 0.0
var recruit_timer := 0.0

@export var members_per_church := 10


func _ready() -> void:
	GameManager.sim_manager = self


func _process(delta) -> void:
	if GameManager.is_paused:
		return
	
	coin_timer = _process_timer(coin_timer, coin_interval, delta, _tick.bind(coin_stat, member_coin_gain))
	if not _has_church_cap():
		recruit_timer = _process_timer(recruit_timer, recruit_interval, delta, _tick.bind(member_stat, member_recruit_gain))


func _process_timer(timer: float, interval: float, delta: float, tick: Callable) -> float:
	timer += delta
	
	while timer >= interval:
		tick.call()
		timer -= interval
	
	return timer


func _tick(stat: Stat, per_gain: float) -> void:
	var members = GameManager.stats_manager.get_stat(member_stat)
	GameManager.stats_manager.add_stat(stat, members * per_gain)


func _has_church_cap() -> bool:
	var members = GameManager.stats_manager.get_stat(member_stat)
	var church = GameManager.stats_manager.get_stat(church_stat)
	var max_members = church * members_per_church
	if members > max_members:
		GameManager.stats_manager.set_stat(member_stat, max_members)
		GameManager.stats_manager.stat_cost_failed.emit(church_stat)
		return true
	
	return false


func modify_recruit_rate(amount: float):
	member_recruit_gain += amount


func modify_coin_rate(amount: float):
	member_coin_gain += amount


func modify_recruit_interval(amount: float):
	recruit_interval = max(0.1, recruit_interval + amount)


func modify_coin_interval(amount: float):
	coin_interval = max(0.1, coin_interval + amount)


func modify_church_capacity(amount: int):
	members_per_church += amount
	_has_church_cap()


func get_stat_detail_description(stat: Stat) -> String:
	match stat:
		member_stat:
			return get_recruit_detail()
		church_stat:
			return get_church_detail()
		coin_stat:
			return get_coin_detail()
		soul_stat:
			return get_soul_detail()
		loyalty_stat:
			return get_loyal_detail()
		
	return ""


func get_recruit_detail() -> String:
	var recruit_amount := int(GameManager.stats_manager.get_stat(member_stat) * member_recruit_gain)
	return "Rate: %s%.1f every %.1fs\n(%.2f per person)" % [
		_get_sign(recruit_amount), 
		recruit_amount, 
		recruit_interval, 
		member_recruit_gain
	]


func get_church_detail() -> String:
	var member_capacity := int(GameManager.stats_manager.get_stat(church_stat) * members_per_church)
	return "Cap: " + str(member_capacity) + " ppl" + "\n" +  "(" + str(members_per_church) + " per church)" 


func get_coin_detail() -> String:
	var coin_amount := int(GameManager.stats_manager.get_stat(member_stat) * member_coin_gain)
	return "Rate: %s%.1f every %.1fs\n(%.2f per person)" % [
		_get_sign(coin_amount), 
		coin_amount, 
		coin_interval, 
		member_coin_gain
	]


func get_soul_detail() -> String:
	var soul_amonut := int(GameManager.task_manager.get_soul_gain_per_sacrifice())
	return _get_sign(soul_amonut) + str(soul_amonut) + " per sacrificed person" + "\n" + "(used for event/upgrade)"


func get_loyal_detail() -> String:
	var loyalty: float = 1.0 + GameManager.stats_manager.get_stat(loyalty_stat) * 0.02
	return "Rate: " + _get_sign(loyalty) + str(loyalty) + "\n" + "(for recruit/coin efficiency)"


func _get_sign(num) -> String:
	return "+" if num >= 0 else "-"
