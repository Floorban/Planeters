extends Panel
class_name BuildingInfo

@onready var name_label: Label = %NameLabel
@onready var production_label: Label = %ProductionLabel
@onready var production_in_total: Label = %ProductionInTotal
@onready var production_last_round: Label = %ProductionLastRound
@onready var remove_button: Button = %RemoveButton
func _ready() -> void:
	remove_button.pressed.connect(_on_remove_pressed)

func set_building_info(building: Building) -> void:
	name_label.text = building.building_name
	production_label.text = "$ " + str(building.procude_points) + " / " + str(building.produce_duration) + "s"
	production_in_total.text = "In Total: " + str(building.produced_in_total)
	production_last_round.text = "This Round: " + str(building.produced_round)

func _on_remove_pressed() -> void:
	pass
