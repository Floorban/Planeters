class_name TaskProgress extends VBoxContainer


@onready var task_progress_bar: ProgressBar = $TaskProgressBar
@onready var task_label: Label = $TaskLabel


func start_action(action_name:String, duration:float):
	task_progress_bar.value = 0
	task_label.text = action_name


func _ready():
	$Timer.timeout.connect(_tick)

func _tick():
	task_progress_bar.value += task_progress_bar.step
	if task_progress_bar.value >= task_progress_bar.max_value:
		task_progress_bar.value = 0
