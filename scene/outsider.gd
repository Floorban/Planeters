class_name Outsider
extends Character

signal trust_changed(outsider: Outsider, current: float, max_value: float)
signal patience_changed(outsider: Outsider, current: float, max_value: float)
signal converted(outsider: Outsider)
signal expired(outsider: Outsider)
signal trust_clicked(outsider: Outsider)

@export var max_trust := 10.0
@export var trust_per_click := 1.0
@export var max_patience := 45.0
@export var represented_count := 1

var trust := 0.0
var patience := 45.0


func _ready() -> void:
	super._ready()
	patience = max_patience
	character_sprite.modulate = Color(0.78, 0.74, 0.7, 1.0)


func _process(delta: float) -> void:
	super._process(delta)
	if is_hover_paused:
		return
	if state == CharacterState.BEING_KILLED or state == CharacterState.DEAD or state == CharacterState.ESCAPING:
		return
	patience = max(0.0, patience - delta)
	patience_changed.emit(self, patience, max_patience)
	if patience <= 0.0:
		state = CharacterState.ESCAPING
		target_position = GameManager.world_manager.exit_point.global_position


func _handle_selected(_is_selected: bool) -> void:
	apply_trust_click()


func apply_trust_click(amount: float = trust_per_click) -> void:
	trust = min(max_trust, trust + amount)
	trust_clicked.emit(self)
	trust_changed.emit(self, trust, max_trust)
	if trust >= max_trust:
		converted.emit(self)


func get_hover_title() -> String:
	return "Outsider x%d" % represented_count if represented_count > 1 else "Outsider"


func get_hover_lines() -> Array[String]:
	return [
		"Trust: %d / %d" % [int(trust), int(max_trust)],
		"Patience: %d / %d" % [int(ceil(patience)), int(max_patience)],
		"Click to recruit"
	]
