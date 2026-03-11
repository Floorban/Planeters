class_name WorldManager
extends Node2D

@export var character_scene : PackedScene
@export var square_center : Marker2D
@export var exit_point : Marker2D

var characters : Array[Character] = []
@export var max_visible_cultists := 0
var current_members := 0

func _ready():
	await get_tree().process_frame
	GameManager.world_manager = self
	GameManager.stats_manager.stat_changed.connect(_on_stat_changed)
	max_visible_cultists = GameManager.sim_manager.members_per_church * GameManager.stats_manager.get_stat(GameManager.sim_manager.church_stat)


func _on_stat_changed(stat: Stat, value: float):
	if stat != GameManager.sim_manager.member_stat:
		if stat == GameManager.sim_manager.church_stat:
			max_visible_cultists = GameManager.sim_manager.members_per_church * GameManager.stats_manager.get_stat(stat)
		return

	var target := int(value)

	if target > current_members:
		_spawn_members(target - current_members)
	elif target < current_members:
		if randf() > 0.8:
			_remove_members(current_members - target)
		else:
			sacrifice_member()

	current_members = target


func _spawn_members(amount):
	if current_members > max_visible_cultists:
		return
		
	for i in amount:
		var c : Character = character_scene.instantiate()
		add_child(c)
		var rand_scale := randf_range(1.3, 1.7)
		c.scale = Vector2(rand_scale, rand_scale)

		c.global_position = exit_point.global_position + Vector2(randf_range(-400, 400), randf_range(-50, 20))
		c.target_position = get_random_church_position()
		c.state = Character.CharacterState.WANDERING
		characters.append(c)
		c.character_die.connect(func(): characters.erase(c))


func _remove_members(amount):
	for i in amount:
		if characters.is_empty():
			return

		var c : Character = characters.pop_back()
		c.state = Character.CharacterState.ESCAPING
		c.target_position = exit_point.global_position


func sacrifice_member():
	if characters.is_empty():
		return

	var c : Character = characters.pop_back()
	c.state = Character.CharacterState.BEING_KILLED


func get_random_church_position() -> Vector2:
	return square_center.global_position + Vector2(randf_range(-210, 210),randf_range(-20, 200))
