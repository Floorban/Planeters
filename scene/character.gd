class_name Character
extends CharacterBody2D

enum CharacterState {
	IDLE,
	WANDERING,
	ESCAPING,
	KILLING,
	BEING_KILLED,
	DEAD,
	BEING_DRAGGED,
	LANDING,
	JUST_LANDED
}

var move_speed := 0.0
@export var walk_speed := 500.0
@export var run_speed := 1000.0

var state : CharacterState = CharacterState.IDLE
var target_position : Vector2
var stop_distance := 5
var run_distance := 80

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


func _on_character_hovered(is_hovered: bool) -> void:
	var mode = 1 if is_hovered else 0
	sprite_material.set_shader_parameter("outline_mode", mode)


func _on_character_selected(is_selected: bool) -> void:
	state = CharacterState.BEING_DRAGGED
	character_sprite.play("hang")
	character_hang()


func _on_character_deselected() -> void:
	state = CharacterState.LANDING
	character_sprite.play("land")
	await character_land()
	state = CharacterState.WANDERING


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
	if state == CharacterState.IDLE:
		wander_timer -= delta

		if wander_timer <= 0:
			wander_timer = randf_range(8,15)

			target_position = GameManager.world_manager.get_random_church_position()
			state = CharacterState.WANDERING
	elif state == CharacterState.BEING_DRAGGED:
		global_position = get_global_mouse_position() + Vector2.UP


func _physics_process(delta):
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
			move_speed = run_speed + randf_range(-50, 50)
			character_sprite.play("run")
		else:
			move_speed = walk_speed + randf_range(-50, 50)
			character_sprite.play("walk")
