extends CharacterBody3D
class_name Building

const PLACEMENT_INVALID_MAT = preload("uid://bdusul7a27vv8")
const PLACEMENT_VALID_MAT = preload("uid://utp7ndcuswgq")

@export var building_name: String

@export var meshes: Array[MeshInstance3D]
@onready var ground_checkes: Array[RayCast3D] = [%RayCast3D1, %RayCast3D2, %RayCast3D3, %RayCast3D4]
@onready var influence_area: BuildingInfluenceArea = $BuildingInfluenceArea
@onready var building_info: BuildingInfo = %BuildingInfo

@export var data: BuildingData
var is_placed := false
var produce_timer := 0.0
var produce_duration := 0.0
var procude_points := 0
var produce_effitiency := 1.0

var produced_in_total: int
var produced_round: int

func _ready() -> void:
	produce_duration = data.produced_time
	_reset_produce_timer(produce_duration)
	procude_points = data.produced_points
	GameManager.skill_tree.skill_changed.connect(apply_upgrades)
	mouse_entered.connect(_on_mouse_hovered)
	mouse_exited.connect(_on_mouse_exited)

func _on_mouse_hovered() -> void:
	if not is_placed or GameManager.building_manager.placing:
		return
	building_info.set_building_info(self)
	building_info.visible = true
	influence_area.mesh.visible = true

func _on_mouse_exited() -> void:
	if not is_placed:
		return
	building_info.visible = false
	influence_area.mesh.visible = false

func _process(delta: float) -> void:
	if not is_placed or GameManager.is_paused:
		building_info.visible = false
		return
	var screen_pos = GameManager.world_to_screen(global_position)
	building_info.position = screen_pos + Vector2(building_info.size.x / 4, -building_info.size.y / 2)
	produce_timer -= produce_effitiency * delta
	if produce_timer <= 0:
		produce()
		_reset_produce_timer(produce_duration)

func produce() -> void:
	var amount := procude_points
	GameManager.score(amount)
	produced_in_total += amount
	produced_round += amount
	_play_produce_effect(amount)

func _reset_produce_timer(duration: float) -> void:
	produce_timer = duration

func apply_upgrades(skill: SkillData, level: int) -> void:
	for effect in skill.effects:
		effect.apply(self, level)

func place() -> void:
	is_placed = true
	influence_area.mesh.visible = false
	GameManager.consume_points(data.needed_points)
	set_collision_layer_value(3, true)
	for m in meshes:
		m.material_override = null
	_play_place_effect()

func check_placement() -> bool:
	if not GameManager.can_consume_points(data.needed_points):
		_placement_invalid()
		return false
		
	for ray in ground_checkes:
		if not ray.is_colliding():
			_placement_invalid()
			return false
	
	_placement_valid()
	return true

func _placement_invalid() -> void:
	for m in meshes:
		m.material_override = PLACEMENT_INVALID_MAT

func _placement_valid() -> void:
	for m in meshes:
		m.material_override = PLACEMENT_VALID_MAT

func _play_scale_punch(
	start_scale: Vector3,
	peak_scale: Vector3,
	duration_in: float,
	duration_out: float,
	_trans := Tween.TRANS_BACK,
	_ease := Tween.EASE_OUT
	) -> void:
		
	var tween := create_tween()
	tween.set_parallel(true)
	tween.set_trans(_trans)
	tween.set_ease(_ease)

	for m in meshes:
		m.scale = start_scale
		tween.tween_property(m, "scale", peak_scale, duration_in)
		tween.tween_property(m, "scale", Vector3.ONE, duration_out)
	
	tween.finished.connect(
		func(): 	
		for m in meshes:
			m.scale = Vector3.ONE
		)

func _play_produce_effect(points: int) -> void:
	var strength:float = lerp(1.05, 1.2, produce_effitiency)
	PopupPrompt.display_prompt(
	str(""),
	points,
	GameManager.world_to_screen(global_position),
	0.3
	)

	_play_scale_punch(
		Vector3(1.1, 0.8, 1.1),
		Vector3.ONE * strength,
		0.2,
		0.3,
		Tween.TRANS_SINE,
		Tween.EASE_OUT
	)

func _play_place_effect() -> void:
	_play_scale_punch(
		Vector3(1.2, 0.6, 1.2),
		Vector3.ONE,
		0.0,
		0.25,
		Tween.TRANS_BACK,
		Tween.EASE_OUT
	)
