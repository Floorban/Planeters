extends Node

#region Playback

func ambient(path: String, node: Node = null) -> AudioStreamPlayer2D:
	var instance: AudioStreamPlayer2D
	#TODO: Add sound to queue, and max playable instance
	
	instance = create(path)
	instance.bus = "Ambient"
	instance.position = Vector2.ZERO if Node != null else node.global_position
	
	instance.play()
	
	return instance

func fx(path: String, randomness: float = 1, node: Node = null) -> AudioStreamPlayer2D:
	var instance: AudioStreamPlayer2D
	#TODO: Add sound to queue, and max playable instance
	
	instance = create(path)
	instance.bus = "SFX"
	instance.position = Vector2.ZERO if Node != null else node.global_position
	instance.pitch_scale = randf_range(1 - (10 - randomness), 1 + (10 - randomness))
	
	instance.play()
	
	return instance

func create(path: String) -> AudioStreamPlayer2D:
	var instance: AudioStreamPlayer2D = AudioStreamPlayer2D.new()
	instance.stream = load(path)
	add_child(instance)
	
	return instance

#endregion

#region Modulation

var tween: Tween = null
var modulation: float = 0.2

func lfo_filter(instance: AudioStreamPlayer2D, start, end, duration) -> void:
	var filter = AudioEffectLowPassFilter.new()
	AudioServer.add_bus_effect(AudioServer.get_bus_index(instance.bus), filter, 0)
	
	fade_in(filter, "cutoff_hz", start, end, randf_range(duration * (1 - modulation), duration * (1 + modulation)))

func lfo_pitch(instance: AudioStreamPlayer2D, start, end, duration) -> void:
	var pitch = AudioEffectPitchShift.new()
	AudioServer.add_bus_effect(AudioServer.get_bus_index(instance.bus), pitch, 0)
	
	fade_in(pitch, "pitch_scale", start, end, randf_range(duration * (1 - modulation), duration * (1 + modulation)))

func fade_in(target, property: String, start: float, end: float, duration: float) -> void:
	if tween and tween.is_valid(): tween.kill()
	tween = create_tween()
	tween.tween_property(target, property, end, duration).from(start)
	await tween.finished

	fade_out(target, property, start, end, duration)

func fade_out(target, property: String, start: float, end: float, duration: float) -> void:
	if tween and tween.is_valid(): tween.kill()
	tween = create_tween()
	tween.tween_property(target, property, start, duration).from(end)
	await tween.finished
	fade_in(target, property, start, end, duration)

#endregion

#region TODO
# Audio.muffle([Audio.bus_ambient, Audio.bus_sfx], true)
# Audio.fade_in(ambient())
# Audio.apply_lfo_lf(ambient())
#endregion
