class_name SimulationManager
extends Node

@export var member_stat : Stat
@export var coin_stat : Stat
@export var loyalty_stat : Stat
@export var church_stat : Stat

@export var member_coin_rate := 0.05
@export var member_recruit_rate := 0.01
@export var members_per_church := 10

@export var coin_tick := 0.2
@export var recruit_tick := 0.5

var coin_timer : Timer
var recruit_timer : Timer


func _ready():
	_setup_timers()


func _setup_timers():
	coin_timer = Timer.new()
	add_child(coin_timer)
	coin_timer.wait_time = coin_tick
	coin_timer.autostart = true
	coin_timer.start()
	coin_timer.timeout.connect(_coin_tick)

	recruit_timer = Timer.new()
	add_child(recruit_timer)
	recruit_timer.wait_time = recruit_tick
	recruit_timer.autostart = true
	recruit_timer.start()
	recruit_timer.timeout.connect(_recruit_tick)


func _coin_tick():
	if GameManager.is_paused:
		return

	var members = GameManager.stats_manager.get_stat(member_stat)
	var loyalty = GameManager.stats_manager.get_stat(loyalty_stat)

	var efficiency = _calculate_loyalty_efficiency(loyalty)

	var gain = members * member_coin_rate * efficiency * coin_tick

	GameManager.stats_manager.add_stat(coin_stat, gain)


func _recruit_tick():

	if GameManager.is_paused:
		return

	var members = GameManager.stats_manager.get_stat(member_stat)
	var loyalty = GameManager.stats_manager.get_stat(loyalty_stat)

	var efficiency = _calculate_loyalty_efficiency(loyalty)

	var gain = members * member_recruit_rate * efficiency * recruit_tick

	GameManager.stats_manager.add_stat(member_stat, gain)

	_apply_church_cap()


func _calculate_loyalty_efficiency(loyalty: float) -> float:
	return 1.0 + loyalty * 0.02


func _apply_church_cap():

	var members = GameManager.stats_manager.get_stat(member_stat)
	var church = GameManager.stats_manager.get_stat(church_stat)

	var max_members = church * members_per_church

	if members > max_members:
		GameManager.stats_manager.set_stat(member_stat, max_members)
