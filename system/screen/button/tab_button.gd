class_name TabBtn extends Button

@export var btn_display_name : String

func _ready() -> void:
	text = btn_display_name
	toggled.connect(func(on):
		if on:
			Audio.create_audio(SFXData.SOUND_EFFECT_TYPE.BTN_CONFIRM)
	)
