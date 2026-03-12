class_name Overview
extends SubPanel

var member := 0
@onready var total_member_label: Label = %TotalMemberLabel

var revenue := 0
@onready var total_revenue_label: Label = %TotalRevenueLabel

var souls := 0
@onready var total_soul_label: Label = %TotalSoulLabel

@onready var total_city_label: Label = %TotalCityLabel

var lifetime := 0.0
@onready var total_lifetime_label: Label = %TotalLifetimeLabel

@export var tween_duration := 0.4
@export var tween_transition := Tween.TRANS_QUAD
@export var tween_ease := Tween.EASE_OUT

@onready var world_overview: TextureRect = %WorldOverview


func _ready() -> void:
	GameManager.overview = self


func reset_overview_labels() -> void:
	set_member_label(-member)
	set_revenue_label(-revenue)
	set_soul_label(-souls)
	lifetime = 0.0


func _process(delta: float) -> void:
	if GameManager.is_paused: return
	lifetime += delta
	_update_lifetime_display(lifetime)


func _animate_label_number(label: Label, start_val: int, end_val: int) -> void:
	var tween = create_tween()
	tween.tween_method(
		func(val: int): label.text = _format_number(val), 
		start_val, 
		end_val, 
		tween_duration
	)


func _format_number(n: int) -> String:
	var s = str(n)
	var rs = ""
	for i in range(s.length()):
		if i > 0 and (s.length() - i) % 3 == 0:
			rs += ","
		rs += s[i]
	return rs


func set_member_label(member_amount: int) -> void:
	var old_val = member
	member += member_amount
	_animate_label_number(total_member_label, old_val, member)


func set_revenue_label(revenue_amount: int) -> void:
	var old_val = revenue
	revenue += revenue_amount
	_animate_label_number(total_revenue_label, old_val, revenue)


func set_soul_label(soul_amount: int) -> void:
	var old_val = souls
	souls += soul_amount
	_animate_label_number(total_soul_label, old_val, souls)


func _update_lifetime_display(time_value: float) -> void:
	var seconds := int(time_value) % 60
	var minutes := int(time_value / 60) % 60
	total_lifetime_label.text = "%02d : %02d" % [minutes, seconds]


func set_lifetime_label(time_value: float) -> void:
	lifetime = time_value
	_update_lifetime_display(lifetime)
