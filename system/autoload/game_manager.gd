extends Node

var task_manager: TaskManager
var stats_manager: StatsManager
var upgrades_manager: UpgradesManager
var sim_manager: SimulationManager
var world_manager: WorldManager

var is_paused := false

func check_game_state(paused: bool) -> void:
	is_paused = paused

var camera : Camera
