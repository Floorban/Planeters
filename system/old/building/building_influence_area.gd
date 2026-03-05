extends Area3D
class_name BuildingInfluenceArea

const SPHERE_MAT = preload("uid://cke5n4rmjoj08")

@onready var mesh: MeshInstance3D = $Mesh
@onready var collision_shape: CollisionShape3D = $CollisionShape

@export var influence_radius: float = 5.0
@export var bonus_per_neighbor: int = 1

var nearby_buildings: Array[Building] = []

func _ready() -> void:
	var col := SphereShape3D.new()
	col.radius = influence_radius
	var sphere := SphereMesh.new()
	sphere.radius = influence_radius
	sphere.height = influence_radius * 2
	mesh.mesh = sphere
	mesh.material_override = SPHERE_MAT
	collision_shape.shape = col
	
	Signals.building_placed.connect(_on_building_placed)

func _on_building_placed(new_building: Building):
	if new_building == owner:
		return
	var dist: float = new_building.global_position.distance_to(owner.global_position)
	if dist <= influence_radius:
		nearby_buildings.append(new_building)
		if dist <= new_building.influence_area.influence_radius:
			new_building.influence_area.nearby_buildings.append(owner)

func calculate_points() -> int:
	return nearby_buildings.size() * bonus_per_neighbor
