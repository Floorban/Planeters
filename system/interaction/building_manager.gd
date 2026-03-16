class_name BuildingManager
extends Node2D


@export var building_scene: PackedScene
var cur_building : Building

func _ready() -> void:
	GameManager.building_manager = self


func _process(_delta: float) -> void:
	ghost_building_follow_mouse()


func ghost_building_follow_mouse() -> void:
	if not cur_building:
		return
	
	cur_building.global_position = get_global_mouse_position()


func get_new_building(building_data: BuildingData) -> void:
	if cur_building:
		push_error("already have a building in hand")
		return
	
	var b := building_scene.instantiate() as Building
	add_child(b)
	cur_building = b
	cur_building.init_building(building_data)
