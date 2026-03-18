class_name Character
extends CharacterBody2D

enum CharacterState {
	IDLE,
	WANDERING,
	ESCAPING,
	KILLING,
	BEING_KILLED,
	DEAD
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


func _on_character_hovered(is_hovered: bool) -> void:
	var mode = 1 if is_hovered else 0
	sprite_material.set_shader_parameter("outline_mode", mode)
	print(mode)


func _process(delta):
	if state == CharacterState.IDLE:
		wander_timer -= delta

		if wander_timer <= 0:
			wander_timer = randf_range(8,15)

			target_position = GameManager.world_manager.get_random_church_position()
			state = CharacterState.WANDERING


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
		
