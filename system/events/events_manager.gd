class_name EventsManager
extends Control

@export var events : Array[EventData]
var current_event : EventData
@export var current_event_index : int

@onready var event_description_label: Label = %EventDescriptionLabel
@onready var event_requirement_label: RichTextLabel = %EventRequirementLabel
@onready var event_reward_label: RichTextLabel = %EventRewardLabel


@onready var start_event_button: Button = %StartEventButton
var button_tween : Tween


func _ready() -> void:
	start_event_button.toggled.connect(_on_event_button_toggled)


func _on_event_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		if can_start_new_event():
			spawn_new_event()
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


func spawn_new_event() -> void:
	if events.size() - 1 <= current_event_index:
		return
	current_event_index += 1
	current_event = events[current_event_index]
	
	event_description_label.text = current_event.event_description
	for c in current_event.event_requirements:
		event_requirement_label.append_text(c.to_rich_text(c.amount, true))
	for r in current_event.event_rewards:
		event_reward_label.append_text(r.to_rich_text(r.amount, false))


func clear_current_event() -> void:
	current_event = null
	event_description_label.text = "There's no event currently"
	event_requirement_label.clear()
	event_requirement_label.clear()


func can_start_new_event() -> bool:
	return false


func _on_event_finished() -> void:
	for r in current_event.event_rewards:
		GameManager.stats_manager.add_stat(r.stat, r.amount)
	
	
	clear_current_event()
