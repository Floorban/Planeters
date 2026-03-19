class_name Character
extends CharacterBody2D

signal hover_state_changed(character: Character, hovered: bool)
signal selected()
signal deselected()
signal right_selected()

enum CharacterState {
	IDLE,
	WANDERING,
	ESCAPING,
	KILLING,
	BEING_KILLED,
	DEAD,
	BEING_DRAGGED,
	AUTO_MOVING,
	WAITING_IN_QUEUE,
	LANDING,
	JUST_LANDED
}

var move_speed := 0.0
@export var walk_speed := 500.0
@export var run_speed := 1000.0
var speed_multiplier := 1.0

var state : CharacterState = CharacterState.IDLE
var target_position : Vector2
var stop_distance := 5
var run_distance := 80
var is_hover_paused := false

var wander_timer := 0.0

@onready var character_sprite: AnimatedSprite2D = %CharacterSprite
@onready var sprite_material : ShaderMaterial = character_sprite.material
@onready var selectable_component: SelectableComponent = %SelectableComponent


func _ready() -> void:
	if character_sprite and sprite_material:
		character_sprite.material = sprite_material.duplicate()
		sprite_material = character_sprite.material
	sprite_material = character_sprite.material as ShaderMaterial
	selectable_component.hover_change.connect(_on_character_hovered)
	selectable_component.select.connect(_on_character_selected)
	selectable_component.deselect.connect(_on_character_deselected)
	selectable_component.right_select.connect(_on_character_right_selected)
	if GameManager.world_manager:
		set_speed_multiplier(GameManager.world_manager.character_speed_multiplier)


func set_speed_multiplier(value: float) -> void:
	speed_multiplier = max(0.1, value)


func _on_character_hovered(is_hovered: bool) -> void:
	z_index = 3 if is_hovered else 2
	var mode = 1 if is_hovered else 0
	sprite_material.set_shader_parameter("outline_mode", mode)
	is_hover_paused = is_hovered
	hover_state_changed.emit(self, is_hovered)


func _on_character_selected(is_selected: bool) -> void:
	_handle_selected(is_selected)


func _on_character_deselected() -> void:
	_handle_deselected()


func _on_character_right_selected() -> void:
	right_selected.emit()
	_handle_right_selected()


func _handle_selected(_is_selected: bool) -> void:
	pass


func _handle_deselected() -> void:
	pass


func _handle_right_selected() -> void:
	pass


var land_tween : Tween


func character_hang() -> void:
	if land_tween:
		land_tween.kill()
	land_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	var target_pos := position - Vector2(0, 5)
	land_tween.tween_property(self, "position", target_pos, 0.05)
	land_tween.parallel().tween_property(sprite_material, "shader_parameter/shadow_dist", 5.0, 0.1)


func character_land() -> Signal:
	if land_tween:
		land_tween.kill()
	land_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	var target_pos := position + Vector2(0, 5)
	land_tween.tween_property(self, "position", target_pos, 0.2)
	land_tween.parallel().tween_property(sprite_material, "shader_parameter/shadow_dist", 1.0, 0.15)
	land_tween.tween_property(self, "position", target_pos - Vector2(0, 2), 0.15)
	return land_tween.finished


func _process(delta):
	if is_hover_paused and state != CharacterState.BEING_DRAGGED and state != CharacterState.BEING_KILLED and state != CharacterState.DEAD:
		if state != CharacterState.BEING_KILLED and state != CharacterState.DEAD:
			character_sprite.play("idle")
		return
	if state == CharacterState.IDLE:
		wander_timer -= delta

		if wander_timer <= 0:
			wander_timer = randf_range(8,15)

			target_position = GameManager.world_manager.get_random_church_position()
			state = CharacterState.WANDERING
	elif state == CharacterState.BEING_DRAGGED:
		global_position = get_global_mouse_position() + Vector2.UP


func _physics_process(delta):
	if is_hover_paused and state != CharacterState.BEING_DRAGGED and state != CharacterState.BEING_KILLED and state != CharacterState.DEAD:
		velocity = Vector2.ZERO
		return
	match state:
		CharacterState.BEING_KILLED:
			character_sprite.play("die")
			character_sprite.modulate = Color(1.825, 0.0, 0.0, 1.0)
			await character_sprite.animation_finished
			queue_free()
		CharacterState.WANDERING:
			_move_to_target(delta)
		CharacterState.ESCAPING:
			_move_to_target(delta)
		CharacterState.AUTO_MOVING:
			_move_to_target(delta)


func start_being_killed() -> void:
	state = CharacterState.BEING_KILLED


func get_hover_title() -> String:
	return "Character"


func get_hover_lines() -> Array[String]:
	return []


func _move_to_target(delta):
	var dir = (target_position - global_position).normalized()
	character_sprite.flip_h = true if dir.x < 0 else false
	velocity = dir * move_speed * delta
	move_and_slide()

	if global_position.distance_to(target_position) < stop_distance:
		state = CharacterState.IDLE
		character_sprite.play("idle")
	else:
		if global_position.distance_to(target_position) > run_distance:
			move_speed = (run_speed * speed_multiplier) + randf_range(-50, 50)
			character_sprite.play("run")
		else:
			move_speed = (walk_speed * speed_multiplier) + randf_range(-50, 50)
			character_sprite.play("walk")
