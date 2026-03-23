extends HBoxContainer

@onready var button_eng: Button = %ButtonENG
@onready var button_cn: Button = %ButtonCN
@onready var button_ja: Button = %ButtonJA


func _ready() -> void:
	button_eng.pressed.connect(_on_english_btn_pressed)
	button_cn.pressed.connect(_on_chinese_btn_pressed)
	button_ja.pressed.connect(_on_japanese_btn_pressed)


func _on_english_btn_pressed() -> void:
	TranslationServer.set_locale("en")


func _on_chinese_btn_pressed() -> void:
	TranslationServer.set_locale("zh_CN")


func _on_japanese_btn_pressed() -> void:
	TranslationServer.set_locale("ja")
