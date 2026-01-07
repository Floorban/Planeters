extends Control
class_name SkillTree

signal skill_changed(skill: SkillData, level: int)

@export var skill_nodes: Array[SkillNode]
var skills: Array[SkillData]

var skill_levels: Dictionary[SkillData, int] = {}

func _ready() -> void:
	GameManager.skill_tree = self
	for skill_node in skill_nodes:
		skills.append(skill_node.skill)
	for skill in skills:
		skill_levels[skill] = 0

func toggle_skill_tree(open: bool) -> void:
	visible = open
	if open:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func unlock(skill: SkillData) -> void:
	if not can_unlock(skill):
		return
	skill_levels[skill] += 1
	skill_changed.emit(skill, skill_levels[skill])

func get_level(skill: SkillData) -> int:
	return skill_levels.get(skill, 0)

func is_unlocked(skill: SkillData) -> bool:
	return get_level(skill) > 0

func can_unlock(skill: SkillData) -> bool:
	return get_level(skill) < skill.max_level

func _on_button_pressed() -> void:
	GameManager.next_level()
