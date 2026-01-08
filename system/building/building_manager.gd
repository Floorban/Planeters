extends Node3D
class_name BuildingManager

const MAX_DIST = 1000.0
var enabled := true

@onready var info_panel: Panel = $BuildingDeck/InfoPanel
@onready var name_label: Label = $BuildingDeck/InfoPanel/VBoxContainer/NameLabel
@onready var production_label: Label = $BuildingDeck/InfoPanel/VBoxContainer/ProductionLabel
@onready var price_label: Label = $BuildingDeck/InfoPanel/VBoxContainer/PriceLabel

@onready var item_list: ItemList = $BuildingDeck/ItemList
@export var buildings_in_deck: Array[BuildingItemData]
var placed_buildings: Array[Building]

var selecting_building: Building
var selecting_building_data: BuildingItemData
var placing := false
var can_place := false

func _ready() -> void:
	GameManager.building_manager = self
	_init_item_list()
	item_list.item_selected.connect(_on_item_selected)

func _process(_delta: float) -> void:
	if can_place and PlayerInput.is_lmb_just_clicked():
		placing = false
		can_place = false
		selecting_building.place()
		placed_buildings.append(selecting_building)
		Signals.building_placed.emit(selecting_building)
		selecting_building = null
		selecting_building_data = null
		item_list.deselect_all()
		set_info_panel(false)
	if placing and PlayerInput.is_rmb_just_clicked():
		placing = false
		can_place = false
		selecting_building.queue_free()
		selecting_building = null
		selecting_building_data = null
		item_list.deselect_all()
		set_info_panel(false)

@export var snap_distance: float = 3.0 # tp if mouse gets too far away
var needs_snap: bool = false

func _physics_process(delta: float) -> void:
	if not selecting_building or not enabled:
		return

	var cam := get_viewport().get_camera_3d()
	var mouse_pos := get_viewport().get_mouse_position()
	var ray_start : Vector3 = cam.project_ray_origin(mouse_pos)
	var dir : Vector3 = cam.project_ray_normal(mouse_pos)
	
	var space_state = get_world_3d().direct_space_state
	var p := PhysicsRayQueryParameters3D.create(ray_start, ray_start + dir * MAX_DIST)
	p.collision_mask = 1 << 1
	
	var result := space_state.intersect_ray(p)

	if result:
		var target_pos = result.position
		var surface_normal = result.normal
		
		var current_basis = selecting_building.global_transform.basis
		var current_forward = -current_basis.z 
		var new_right = current_forward.cross(surface_normal).normalized()
		
		if new_right.length() < 0.001:
			new_right = current_basis.x
			
		var new_forward = surface_normal.cross(new_right).normalized()
		var new_basis = Basis(new_right, surface_normal, -new_forward).orthonormalized()
		var move_diff = target_pos - selecting_building.global_position
		
		if result.collider is Building:
			needs_snap = true
		else:
			if needs_snap and move_diff.length() > snap_distance:
				selecting_building.global_position = target_pos
				selecting_building.global_transform.basis = new_basis
				selecting_building.velocity = Vector3.ZERO 
				needs_snap = false
			else:
				selecting_building.velocity = move_diff * 10.0
				selecting_building.move_and_slide()
				
				selecting_building.global_transform.basis = selecting_building.global_transform.basis.slerp(
					new_basis, 
					0.2
				)

		can_place = selecting_building.check_placement()

	if Input.is_action_just_pressed("wheel_up"):
		selecting_building.rotate_object_local(Vector3.UP, PI/4)
	if Input.is_action_just_pressed("wheel_down"):
		selecting_building.rotate_object_local(Vector3.UP, -PI/4)

func activate_building_manager() -> void:
	enabled = true

func deactivate_building_manager() -> void:
	enabled = false
	placing = false
	can_place = false
	if (selecting_building): selecting_building.queue_free()
	selecting_building = null
	selecting_building_data = null
	item_list.deselect_all()
	set_info_panel(false)

func init_new_round() -> void:
	activate_building_manager()
	for b in placed_buildings:
		b.produced_round = 0

func _init_item_list() -> void:
	if buildings_in_deck.size() <= 0:
		return
	item_list.clear()
	for b in buildings_in_deck:
		item_list.add_icon_item(b.building_icon)

func _on_item_selected(index: int) -> void:
	if not enabled:
		return

	if placing:
		can_place = false
		selecting_building.queue_free()
	selecting_building = buildings_in_deck[index].building_scene.instantiate()
	selecting_building_data = buildings_in_deck[index]
	placing = true
	Planet.add_child(selecting_building)
	set_info_panel(true)

func set_info_panel(open: bool) -> void:
	if open:
		name_label.text = selecting_building.building_name
		production_label.text = "$ " + str(selecting_building.data.produced_points) + " / " + str(selecting_building.data.produced_time) + "s"
		price_label.text = "$ " + str(selecting_building.data.needed_points)
		info_panel.visible = true
	else:
		info_panel.visible = false
