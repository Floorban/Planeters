extends Node

var is_paused := false

@onready var game_ui: GameUI = $GameUI
var skill_tree: SkillTree
var building_manager: BuildingManager

var current_score: int
var current_max_score: int = 2000000

func _ready() -> void:
	score(50000)

func score(added_score: int) -> void:
	current_score += added_score
	game_ui.update_score_ui(float(current_score), float(current_max_score))
	if current_score >= current_max_score:
		check_game_state(true)
		building_manager.deactivate_building_manager()
		skill_tree.toggle_skill_tree(true)

func can_consume_points(amount: int) -> bool:
	if current_score - amount < 0:
		return false
	return true

func consume_points(amount: int) -> void:
	current_score -= amount
	game_ui.update_score_ui(float(current_score), float(current_max_score))

func world_to_screen(world_pos: Vector3) -> Vector2:
	var cam := get_viewport().get_camera_3d()
	if not cam:
		return Vector2.ZERO
	return cam.unproject_position(world_pos)

func check_game_state(paused: bool) -> void:
	is_paused = paused

func next_level() -> void:
	check_game_state(false)
	skill_tree.toggle_skill_tree(false)
	current_max_score *= 5 
	game_ui.update_score_ui(float(current_score), float(current_max_score))
	building_manager.init_new_round()
