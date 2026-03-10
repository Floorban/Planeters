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

@export var move_speed := 500.0

var state : CharacterState = CharacterState.IDLE
var target_position : Vector2
var stop_distance := 5

var wander_timer := 0.0

func _process(delta):
	if state == CharacterState.IDLE:
		wander_timer -= delta

		if wander_timer <= 0:
			wander_timer = randf_range(2,6)

			target_position = GameManager.world_manager.get_random_church_position()
			state = CharacterState.WANDERING


func _physics_process(delta):
	match state:
		CharacterState.WANDERING:
			_move_to_target(delta)
		CharacterState.ESCAPING:
			_move_to_target(delta)


func _move_to_target(delta):
	var dir = (target_position - global_position).normalized()
	velocity = dir * move_speed * delta
	move_and_slide()

	if global_position.distance_to(target_position) < stop_distance:
		state = CharacterState.IDLE
