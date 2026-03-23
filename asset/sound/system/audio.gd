extends Node2D

#region Init

@export var library: Array[SoundEvent]
var bank: Dictionary = {}

func initiate_library():
	for event: SoundEvent in library:
		bank[event.name] = event

func _ready() -> void: initiate_library()

#endregion

#region Playback

func play(sound_name: SoundEvent.Name) -> void:
	var event: SoundEvent = try_create_event(sound_name)
	
	if not event.is_below_playback_limit(): return
	
	var instance: AudioStreamPlayer = try_create_instance(event)
	
	instance.play()
	event.set_sound_count(1)

func try_create_event(event_name: SoundEvent.Name) -> SoundEvent:
	if not bank.has(event_name): return
	return bank[event_name]

func try_create_instance(event: SoundEvent) -> AudioStreamPlayer:
	var instance: AudioStreamPlayer = AudioStreamPlayer.new()
	add_child(instance)
	
	instance.stream = event.get_sound_file()
	return instance

func stop_audio(name: SoundEvent.Name) -> void:
	for event in get_children():
		if event.stream == library[name].file:
			event.stop()

#endregion
