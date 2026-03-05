class_name Dashboard extends SubPanel


@onready var button_drone: Button = %ButtonDrone
@onready var buton_sell: Button = %ButonSell
@onready var button_dig: Button = %ButtonDig
var buttons : Array[Button]

@onready var progress_info_1: VBoxContainer = %ProgressInfo1
@onready var progress_info_2: VBoxContainer = %ProgressInfo2
@onready var progress_info_3: VBoxContainer = %ProgressInfo3


func _ready() -> void:
	buttons = [button_drone, buton_sell, button_dig]
	button_drone.toggled.connect(_send_drone)
	buton_sell.toggled.connect(_sell_inventory)
	button_dig.toggled.connect(_dig_plenet)


func _send_drone(toggled_on: bool) -> void:
	if toggled_on:
		_disable_other_buttons(button_drone, true)
		print("start sending drone")
	else:
		_disable_other_buttons(button_drone, false)
		print("drone sent")


func _sell_inventory(toggled_on: bool) -> void:
	if toggled_on:
		_disable_other_buttons(buton_sell, true)
		print("start selling")
	else:
		_disable_other_buttons(buton_sell, false)
		print("inventory sold")


func _dig_plenet(toggled_on: bool) -> void:
	if toggled_on:
		_disable_other_buttons(button_dig, true)
		print("start digging planet")
	else:
		_disable_other_buttons(button_dig, false)
		print("planet dug")


func _disable_other_buttons(active_btn: Button, disable: bool) -> void:
	for b in buttons:
		if b != active_btn:
			b.disabled = disable
