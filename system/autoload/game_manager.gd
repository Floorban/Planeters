extends Node

var task_manager: TaskManager
var stats_manager: StatsManager
var upgrades_manager: UpgradesManager
var sim_manager: SimulationManager
var world_manager: WorldManager
var event_manager: EventManager
var building_manager: BuildingManager
var building_shop: BuildingShopManager
var panel_manager: PanelManager


func toggle_upgrades_panel() -> void:
	check_game_state(not is_paused)
	panel_manager.fade_in_out_component._on_panel_toggle(is_paused)


func restart_game() -> void:
	panel_manager.overview_panel.reset_overview_labels()
	event_manager.reset_event_manager()


var is_paused := false

func check_game_state(paused: bool) -> void:
	is_paused = paused


func game_over() -> void:
	is_paused = true
	#Audio.create_audio(SFXData.SOUND_EFFECT_TYPE.ENDING)
