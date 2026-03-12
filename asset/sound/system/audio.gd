extends Node2D

var sound_effect_dict: Dictionary = {}

@export var sound_effects: Array[SFXData]


func _ready() -> void:
	for sound_effect: SFXData in sound_effects:
		sound_effect_dict[sound_effect.type] = sound_effect
		sound_effect.reset_extra_pitch_step()


#func create_2d_audio_at_location(type: SFXData.SOUND_EFFECT_TYPE, location: Vector2) -> void:
	#if sound_effect_dict.has(type):
		#var sound_effect: SFXData = sound_effect_dict[type]
		#if sound_effect.has_open_limit():
			#sound_effect.change_audio_count(1)
			#var new_2D_audio: AudioStreamPlayer2D = AudioStreamPlayer2D.new()
			#add_child(new_2D_audio)
			#new_2D_audio.position = location
			#new_2D_audio.stream = sound_effect.sound_effect
			#new_2D_audio.volume_db = sound_effect.volume
			#new_2D_audio.pitch_scale = sound_effect.pitch_scale
			#new_2D_audio.pitch_scale += randf_range(-sound_effect.pitch_randomness, sound_effect.pitch_randomness )
			#new_2D_audio.finished.connect(sound_effect.on_audio_finished)
			#new_2D_audio.finished.connect(new_2D_audio.queue_free)
			#new_2D_audio.play()
	#else:
		#push_error("Audio Manager cant find setting for type ", type)


func create_audio(type: SFXData.SOUND_EFFECT_TYPE) -> void:
	if sound_effect_dict.has(type):
		var sound_effect: SFXData = sound_effect_dict[type]
		if sound_effect.has_open_limit():
			sound_effect.change_audio_count(1)
			var new_audio: AudioStreamPlayer = AudioStreamPlayer.new()
			add_child(new_audio)
			new_audio.stream = sound_effect.sound_effect
			new_audio.volume_db = sound_effect.volume
			var ladder_offset = sound_effect.audio_count * sound_effect.pitch_step
			var random_offset = randf_range(-sound_effect.pitch_randomness, sound_effect.pitch_randomness)
			var final_pitch = sound_effect.pitch_scale + ladder_offset + random_offset + sound_effect.current_pitch_offset
			final_pitch = clamp(final_pitch, 0.01, sound_effect.max_pitch_cap)
			new_audio.pitch_scale = final_pitch
			new_audio.finished.connect(sound_effect.on_audio_finished)
			new_audio.finished.connect(new_audio.queue_free)
			new_audio.play()
	else:
		push_error("Audio Manager cant find setting for type ", type)


# both 2D and normal
func stop_and_free_all_audio() -> void:
	for child in get_children():
		if child is AudioStreamPlayer or child is AudioStreamPlayer2D:
			child.stop()


func stop_audio_by_type(type: SFXData.SOUND_EFFECT_TYPE) -> void:
	for child in get_children():
		if (child is AudioStreamPlayer or child is AudioStreamPlayer2D) and child.stream == sound_effect_dict[type].sound_effect:
			child.stop()
