class_name PanelManager
extends Control

var sub_panels : Array[SubPanel]

@onready var bookmark: Control = %Bookmark
var tab_btns: Array[TabBtn]
var tab_group := ButtonGroup.new()

@onready var selectable_component: SelectableComponent = $SelectableComponent


func _ready() -> void:
	_init_sub_panels()
	selectable_component.hover_change.connect(_on_panel_toggle)


func _init_sub_panels() -> void:
	sub_panels.clear()
	for c in get_children():
		if c is SubPanel:
			c.focus_panel.connect(_on_panel_opened)
			c.hide_panel()
			sub_panels.append(c)
			#if c is Overview:
				#c.world_overview.texture = sub_viewport.get_texture()
			
	if sub_panels.is_empty():
		push_error("doesn't have any sub panels")
		return
	
	_init_tab_btns()


func _init_tab_btns() -> void:
	tab_btns.clear()
	for c in bookmark.get_children():
		if c is TabBtn:
			c.button_group = tab_group
			tab_btns.append(c)
	
	if tab_btns.is_empty():
		push_error("doesn't have any tab buttons left for the panel")
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


var is_hovering := false
@export var panel_folded_pos : Vector2
@export var panel_unfolded_pos : Vector2
var panel_tween: Tween


func _on_panel_toggle(toggled_on: bool) -> void:
	_open_panel() if toggled_on else _close_panel()
	is_hovering = toggled_on


func _open_panel() -> void:
	if is_hovering:
		return
	if panel_tween: panel_tween.kill()
	panel_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	panel_tween.tween_property(self, "position", panel_unfolded_pos, 0.3)


func _close_panel() -> void:
	if not is_hovering:
		return
	if panel_tween: panel_tween.kill()
	panel_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	panel_tween.tween_property(self, "position", panel_folded_pos, 0.2)
	
	panel_tween.tween_callback(func(): position = panel_folded_pos)
