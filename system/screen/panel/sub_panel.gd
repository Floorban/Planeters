class_name SubPanel extends Control

signal focus_panel(panel: SubPanel)


func toggle_panel(toggled_on: bool) -> void:
	if toggled_on: show_panel()
	else: hide_panel()


func hide_panel() -> void:
	hide()


func show_panel() -> void:
	show()
	focus_panel.emit(self)
