class_name TabBtn extends Button

@export var btn_display_name : String

func _ready() -> void:
	text = btn_display_name
	toggled.connect(func(on):
		if on:
			#Sound.fx("res://asset/sound/fx/f_confirm.ogg")
			pass
	)
