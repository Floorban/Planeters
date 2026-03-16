extends Resource
class_name SoundEvent

#region Parameters

@export_group("General")
@export() var file: AudioStreamOggVorbis
@export var sound_type: SoundType = SoundType.SFX
@export_range(0, 10) var sound_limit: int = 5
var sound_count: int = 0

@export_group("Playback")
@export var playback_type: PlaybackType = PlaybackType.Oneshot
@export_range(-0, 10) var volume: float = 1
@export_range(0.1, 10) var pitch: float = 1

@export_subgroup("Advanced")
@export_range(0, 10) var pitch_randomness: float = 1.5 # if not Type.SFX: pitch_randomness 0
@export_range(0, 25) var pitch_step_limit: int = 0
var pitch_step: int = 0

@export_group("Filter")
@export var filters: Array[AudioEffect]

enum SoundType {
	AMBIENT,
	SFX,
	MUSIC,
}

enum PlaybackType {
	Oneshot,
	Looping,
}

#endregion 

#region Getters & Setters

func get_sound_file() -> AudioStreamOggVorbis: return file

func get_sound_type() -> SoundType: return sound_type

func get_playback_type() -> PlaybackType: return playback_type

#endregion

#region Playback

func _is_below_playback_limit() -> bool: return sound_limit >= sound_count

func _add_pitch_step(count: int) -> void: 
	pitch_step += count
	if pitch_step >= pitch_step_limit: pitch_step = 0

#endregion
