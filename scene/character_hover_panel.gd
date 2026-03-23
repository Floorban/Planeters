class_name CharacterHoverPanel
extends PanelContainer

@onready var title_label: Label = %TitleLabel
@onready var line_one_label: Label = %LineOneLabel
@onready var line_two_label: Label = %LineTwoLabel
@onready var line_three_label: Label = %LineThreeLabel

var current_character: Character


func _ready() -> void:
	hide()


func show_character_info(title: String, lines: Array[String], character: Character = null) -> void:
	current_character = character
	title_label.text = title
	line_one_label.text = lines[0] if lines.size() > 0 else ""
	line_two_label.text = lines[1] if lines.size() > 1 else ""
	line_three_label.text = lines[2] if lines.size() > 2 else ""
	show()


func hide_character_info() -> void:
	current_character = null
	hide()


func _process(_delta: float) -> void:
	if not visible:
		return
	if current_character and is_instance_valid(current_character):
		show_character_info(current_character.get_hover_title(), current_character.get_hover_lines(), current_character)
	elif current_character:
		hide_character_info()
		return
	global_position = get_viewport().get_mouse_position() + Vector2(16, 20)
