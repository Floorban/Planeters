extends Node

#region Playback

func ambient(path: String, node: Node = null) -> AudioStreamPlayer2D:
	var instance: AudioStreamPlayer2D
	#TODO: Add sound to queue, and max playable instance
	#TODO: Play based on file path
	
	instance = create(path)
	instance.bus = "Ambient"
	instance.position = Vector2.ZERO if Node != null else node.global_position
	
	instance.play()
	
	return instance

func sfx(path: String, node: Node = null) -> AudioStreamPlayer2D:
	var instance: AudioStreamPlayer2D
	#TODO: Add sound to queue, and max playable instance
	#TODO: Play based on file path
	
	instance = create(path)
	instance.bus = "SFX"
	instance.position = Vector2.ZERO if Node != null else node.global_position
	
	instance.play()
	
	return instance

func create(path: String) -> AudioStreamPlayer2D:
	var instance: AudioStreamPlayer2D = AudioStreamPlayer2D.new()
	instance.stream = load(path)
	
	add_child(instance)
	
	return instance

#endregion

#region Modulation
func lfo_filter(instance: AudioStreamPlayer2D, start, end, duration) -> void:
	var filter = AudioEffectLowPassFilter.new()
	AudioServer.add_bus_effect(AudioServer.get_bus_index(instance.bus), filter, 0)
	fadein(filter, "cutoff_hz", start, end, duration)

func lfo_pitch(instance: AudioStreamPlayer2D, start, end, duration) -> void:
	var pitch = AudioEffectPitchShift.new()
	AudioServer.add_bus_effect(AudioServer.get_bus_index(instance.bus), pitch, 0)
	fadein(pitch, "pitch_scale", start, end, duration)

func fadein(target, property: String, start: float, end: float, duration: float) -> void:
	var tween = create_tween()
	tween.tween_property(target, property, end, duration).from(start)
	await tween.finished
	fadeout(target, property, start, end, duration)

func fadeout(target, property: String, start: float, end: float, duration: float) -> void:
	var tween = create_tween()
	tween.tween_property(target, property, start, duration).from(end)
	await tween.finished
	fadein(target, property, start, end, duration)

#region TODO
# Audio.muffle([Audio.bus_ambient, Audio.bus_sfx], true)
# Audio.fade_in(ambient())
# Audio.apply_lfo_lf(ambient())
#endregion

func _ready() -> void:
	var i_ambient: AudioStreamPlayer2D
	i_ambient = ambient("res://asset/sound/[Cult]a_neutral.ogg")
	lfo_filter(i_ambient, 1000, 2000, 8)
	lfo_pitch(i_ambient, 0.5, 0.6, 3)
