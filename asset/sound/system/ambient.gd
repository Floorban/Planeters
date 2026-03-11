extends Node

func _ready() -> void:
	var i_ambient: AudioStreamPlayer2D
	i_ambient = Audio.ambient("res://asset/sound/ambient/[Cult]a_neutral.ogg")
	Audio.lfo_filter(i_ambient, 1300, 1500, 15)
	Audio.lfo_pitch(i_ambient, 0.5, 0.6, 15)
