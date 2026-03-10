class_name MainScreen extends Control

@onready var panel_container: Control = %PanelContainer
@onready var taskbar: Control = %Taskbar

var sub_panels : Array[SubPanel]

var tab_btns: Array[TabBtn]
var tab_group := ButtonGroup.new()

#@onready var camera: Camera = %Camera

func _ready() -> void:
	_init_sub_panels()
	#GameManager.camera = camera
	#camera.global_position = global_position + size / 2


func _init_sub_panels() -> void:
	sub_panels.clear()
	for c in panel_container.get_children():
		if c is SubPanel:
			c.focus_panel.connect(_on_panel_opened)
			c.hide_panel()
			sub_panels.append(c)
	
	if sub_panels.is_empty():
		push_error("doesn't have any sub panels")
		return
	
	_init_tab_btns()


func _init_tab_btns() -> void:
	tab_btns.clear()
	for c in taskbar.get_children():
		if c is TabBtn:
			c.button_group = tab_group
			tab_btns.append(c)
	
	if tab_btns.is_empty():
		push_error("doesn't have any tab buttons")
		return
	
	_connect_tab_btns_to_sub_panels()


func _connect_tab_btns_to_sub_panels() -> void:
	for i in range(sub_panels.size()):
		tab_btns[i].toggled.connect(sub_panels[i].toggle_panel)
	
	#open first panel by default
	tab_btns[0].button_pressed = true


func _on_panel_opened(active_panel: SubPanel) -> void:
	for p in sub_panels:
		if p != active_panel:
			p.hide_panel()
