extends Control
class_name GameUI

@onready var progress_bar: TextureProgressBar = $ProgressBar
@onready var score_label: Label = $ProgressBar/Label

func _ready() -> void:
	init_score_ui()

func init_score_ui() -> void:
	progress_bar.value = 0.0
	score_label.text = "0"

func update_score_ui(score: float, max_score: float) -> void:
	progress_bar.max_value = max_score
	progress_bar.value = clampf(score, 0, max_score)
	score_label.text = str(score)
