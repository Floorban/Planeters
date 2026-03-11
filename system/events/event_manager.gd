class_name EventManager
extends Control

@export var events : Array[EventData]
var current_event : EventData
@export var current_event_index : int

var event_timer : float
var event_expire_timer : float
@export var expire_duration : float
var can_start_event := false

var new_event_timer : float
@export var new_event_gap : float
@export var new_event_gap_range : float

@onready var event_description_label: Label = %EventDescriptionLabel
@onready var event_requirement_label: RichTextLabel = %EventRequirementLabel
@onready var event_reward_label: RichTextLabel = %EventRewardLabel

@onready var start_event_button: Button = %StartEventButton
var button_tween : Tween


func _ready() -> void:
	start_event_button.toggled.connect(_on_event_button_toggled)
	reset_event_manager()


func _on_event_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		if can_start_new_event():
			start_event()
			start_event_button.disabled = true
		else:
			start_event_failed()


func start_event_failed() -> void:
	start_event_button.button_pressed = false
	var og_color = Color.WHITE
	start_event_button.modulate = og_color
	
	if button_tween:
		button_tween.kill()
	button_tween = create_tween()
	button_tween.tween_property(start_event_button, "modulate", Color(0.796, 0.0, 0.0, 1.0), 0.08)
	button_tween.tween_property(start_event_button, "modulate", og_color, 0.1)
	button_tween.tween_callback(func(): start_event_button.modulate = og_color)


func _process(delta: float) -> void:
	if GameManager.is_paused: return
	_run_event_progress(delta)
	_run_event_cooldown(delta)
	_run_event_spawn_cooldown(delta)


func _run_event_progress(delta) -> void:
	if not current_event or can_start_event:
		return
	
	event_timer += delta
	if event_timer >= current_event.event_duration:
		_on_event_finished()


func _run_event_cooldown(delta) -> void:
	if not can_start_event:
		return
		
	event_expire_timer += delta
	if event_expire_timer >= expire_duration:
		_on_event_expired()


func _run_event_spawn_cooldown(delta) -> void:
	if can_start_event:
		return
		
	new_event_timer += delta
	if new_event_timer >= new_event_gap + randf_range(-new_event_gap_range, new_event_gap_range):
		spawn_new_event()


func spawn_new_event() -> void:
	if events.size() - 1 < current_event_index:
		return
	var new_event = events[current_event_index]
	
	event_description_label.text = new_event.event_description
	for c in new_event.event_requirements:
		event_requirement_label.append_text(c.to_rich_text(c.amount, true, false) + "  ")
	for r in new_event.event_rewards:
		event_reward_label.append_text(r.to_rich_text(r.amount, false, false) + "  ")

	can_start_event = true
	new_event_timer = 0.0
	current_event = new_event
	current_event_index += 1


func clear_current_event() -> void:
	can_start_event = false
	event_expire_timer = 0.0
	event_timer = 0.0
	current_event = null
	event_description_label.text = "There's no event currently"
	event_requirement_label.clear()
	event_reward_label.clear()


func can_start_new_event() -> bool:
	if not current_event:
		return false
	for c in current_event.event_requirements:
		if GameManager.stats_manager.get_stat(c.stat) < c.amount:
			GameManager.stats_manager.stat_cost_failed.emit(c.stat)
			return false
	return true


func start_event() -> void:
	can_start_event = false


func _on_event_finished() -> void:
	for r in current_event.event_rewards:
		GameManager.stats_manager.add_stat(r.stat, r.amount)
	start_event_button.disabled = false
	clear_current_event()


func _on_event_expired() -> void:
	clear_current_event()


func reset_event_manager() -> void:
	_on_event_expired()
	current_event_index = 0
