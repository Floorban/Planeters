class_name TaskSlot
extends VBoxContainer

signal task_finished(task : Task)

@onready var task_progress_bar: ProgressBar = $TaskProgressBar
@onready var task_label: Label = $TaskLabel

var task_timer := 0.0
var task_interval := 0.0

var current_task : Task
var is_running := false


func _ready() -> void:
	hide()


func start_task(task : Task) -> void:
	current_task = task
	is_running = true
	task_progress_bar.value = 0
	task_label.text = task.task_description
	
	task_timer = 0.0
	var final_duration: float = task.duration * GameManager.task_manager.get_duration_multiplier(task)
	task_interval = final_duration / task_progress_bar.max_value
	show()


func _process(delta: float) -> void:
	if current_task != null:
		task_timer = _process_timer(task_timer, task_interval, delta, _tick)


func _process_timer(timer: float, interval: float, delta: float, tick: Callable) -> float:
	if not is_running :
		return 0.0
		
	if interval <= 0:
		tick.call()
		return 0.0
		
	timer += delta
	
	while timer >= interval:
		tick.call()
		timer -= interval
	
	return timer


func _tick() -> void:
	task_progress_bar.value += task_progress_bar.step
	if task_progress_bar.value >= task_progress_bar.max_value:
		is_running = false
		task_progress_bar.value = 0
		task_finished.emit(current_task)
		current_task = null
		
		hide()


## old timer logic
#var task_timer : Timer
#
#func _ready() -> void:
	#task_timer = Timer.new()
	#add_child(task_timer)
	#task_timer.timeout.connect(_tick)
	#hide()
#
#
#func start_task(task : Task) -> void:
	#current_task = task
	#is_running = true
	#task_progress_bar.value = 0
	#task_label.text = task.task_description
	#
	#task_timer.wait_time = task.duration / task_progress_bar.max_value
	#task_timer.start()
	#show()
#
#
#func _tick() -> void:
	#task_progress_bar.value += task_progress_bar.step
	#if task_progress_bar.value >= task_progress_bar.max_value:
		#task_timer.stop()
		#is_running = false
		#task_progress_bar.value = 0
		#task_finished.emit(current_task)
		#current_task = null
		#hide()
