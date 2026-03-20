class_name PanelManager
extends Control

var sub_panels : Array[SubPanel]

@onready var bookmark: Control = %Bookmark
var tab_btns: Array[TabBtn]
var tab_group := ButtonGroup.new()

@onready var fade_in_out_component: FadeInOutComponent = %FadeInOutComponent

@onready var overview_panel: Overview = $OverviewPanel
@onready var upgrades_panel: UpgradesManager = $UpgradesManager


func _ready() -> void:
	GameManager.panel_manager = self
	_init_sub_panels()
	fade_in_out_component._on_panel_toggle(false)


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
