class_name MainScreen extends Control

@onready var panel_container: Control = %PanelContainer
@onready var taskbar: Control = %Taskbar

var sub_panels : Array[SubPanel]

var tab_btns: Array[TabBtn]
var tab_group := ButtonGroup.new()

#@onready var camera: Camera = %Camera

@onready var button_eng: Button = %ButtonENG
@onready var button_cn: Button = %ButtonCN
@onready var button_ja: Button = %ButtonJA


func _on_english_btn_pressed() -> void:
	TranslationServer.set_locale("en")


func _on_chinese_btn_pressed() -> void:
	TranslationServer.set_locale("zh_CN")


func _on_japanese_btn_pressed() -> void:
	TranslationServer.set_locale("ja")


func set_ui_font(font: Font):
	get_tree().root.theme.default_font = font


func _ready() -> void:
	_init_sub_panels()
	button_eng.pressed.connect(_on_english_btn_pressed)
	button_cn.pressed.connect(_on_chinese_btn_pressed)
	button_ja.pressed.connect(_on_japanese_btn_pressed)
	#GameManager.camera = camera
	#camera.global_position = global_position + size / 2


func _init_sub_panels() -> void:
	sub_panels.clear()
	for c in panel_container.get_children():
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
