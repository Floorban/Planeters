class_name SFXData 
extends Resource

enum SOUND_EFFECT_TYPE {
	GET_MEMBER,
	SACRIFICE,
	BUILD,
	COIN,
	SOUL,
	EVENT_STARTED,
	EVENT_FINISHED,
	BTN_HOVER,
	BTN_CONFIRM,
	BTN_FAIL,
	UPGRADE_PURCHASE,
}

@export_range(0, 10) var limit: int = 5
@export var type: SOUND_EFFECT_TYPE
@export var sound_effect: AudioStreamOggVorbis
@export_range(-40, 20) var volume: float = 0
# for random pitch
@export_range(0.0, 4.0,.01) var pitch_scale: float = 1.0
@export_range(0.0, 1.0,.01) var pitch_randomness: float = 0.2
# for incremental pitch
@export_range(0.0, 0.5) var pitch_step: float = 0.05 
@export_range(1.0, 5.0) var max_pitch_cap: float = 2.0

var audio_count: int = 0


func change_audio_count(amount: int) -> void:
	audio_count = max(0, audio_count + amount)


func has_open_limit() -> bool:
	return audio_count < limit


func on_audio_finished() -> void:
	change_audio_count(-1)
