extends Node

@export var fx_test: SoundEvent

#region Events

enum Event {
	PLACEHOLDER,
	
	## AMBIENT
	AFX_ATMOSPHERE,
	
	## SOUND EFFECT
	# Actions
	SFX_GET_MEMBER,
	SFX_SACRIFICE_MEMBER,
	SFX_BUILD_CHURCH,
	
	# Stats
	SFX_GAIN_MEMBER,
	SFX_GAIN_CHURCH,
	SFX_GAIN_COIN,
	SFX_GAIN_SOUL,
	
	# Upgrades
	SFX_UPGRADE,
	
	# Events
	SFX_EVENT_START,
	SFX_EVENT_END,
	
	# UI
	SFX_BTN_HOVER,
	SFX_BTN_CONFIRM,
	SFX_BTN_LOCKED,

}

#endregion

#func play(event: Event) -> void:
	#var instance: AudioStreamPlayer = create_stream_player(SoundEvent.get_sound_file())
	#
	#instance.play()

func create_stream_player(file: AudioStreamOggVorbis) -> AudioStreamPlayer:
	var instance: AudioStreamPlayer = AudioStreamPlayer.new()
	instance.stream = file
	add_child(instance)
	
	return instance
