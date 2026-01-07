#@tool
extends Node3D

@export_group("Sphere")
@export_enum("Default Sphere", "Box Sphere") var sphere_type := 0:
	set(new_type):
		sphere_type = new_type
		update_terrain()
		update_water()
@export var radius := 8.0:
	set(new_radius):
		radius = maxf(1.0, new_radius)
		update_terrain()
		update_water()
@export var detail := 64:
	set(new_detail):
		detail = maxi(1, new_detail)
		update_terrain()

@export_group("Terrain")
@export var noise := FastNoiseLite.new():
	set(new_noise):
		noise = new_noise
		noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
		if noise:
			noise.changed.connect(update_terrain)
@export var height := 1.0:
	set(new_height):
		height = maxf(0.0, new_height)
		update_terrain()
		update_water()
@export var terrain_material: Material:
	set(new_terrain_material):
		terrain_material = new_terrain_material
		if terrain.get_surface_count():
			terrain.surface_set_material(0, terrain_material)

@export_group("Water")
@export_range(0.0, 1.0, 0.05) var water_level := 0.0:
	set(new_water_level):
		water_level = new_water_level
		update_water()
@export var water_detail := 64:
	set(new_water_level):
		water_detail = maxi(1, new_water_level)
		update_water()
@export var water_material: Material:
	set(new_water_material):
		water_material = new_water_material
		if water.get_surface_count():
			water.surface_set_material(0, water_material)

var terrain := ArrayMesh.new()
var water := ArrayMesh.new()

@export_group("Collision")
@export var generate_collision := true:
	set(val):
		generate_collision = val
		update_terrain()

var static_body: StaticBody3D
var collision_shape: CollisionShape3D

func _ready() -> void:
	$Terrain.mesh = terrain
	$Water.mesh = water
	update_terrain()
	update_water()

func create_sphere(sphere_radius: float, sphere_detail: int) -> Array:
	if sphere_type == 0:
		var sphere := SphereMesh.new()
		sphere.radius = sphere_radius
		sphere.height = sphere_radius * 2.0
		
		sphere.radial_segments = sphere_detail * 2
		sphere.rings = sphere_detail
		return sphere.get_mesh_arrays()
	
	return BoxSphere.create_sphere(sphere_detail, sphere_radius * 2.0)

@export var noise_scale : float = 0.3

func get_noise(vertex: Vector3) -> float:
	return (noise.get_noise_3dv(vertex.normalized() * noise_scale) + 1.0) / 2.0 * height

func update_terrain() -> void:
	if !terrain or !noise:
		return
	
	var mesh_arrays := create_sphere(radius, detail)
	var vertices: PackedVector3Array = mesh_arrays[ArrayMesh.ARRAY_VERTEX]
	for i: int in vertices.size():
		var vertex := vertices[i]
		vertex += vertex.normalized() * get_noise(vertex)
		vertices[i] = vertex
	
	terrain.clear_surfaces()
	terrain.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, mesh_arrays)
	terrain.surface_set_material(0, terrain_material)
	
	if generate_collision:
		update_collision()
	else:
		remove_collision()

func update_water() -> void:
	if !water or (get_node_or_null("Water") == null):
		return
	
	if water_level == 0.0:
		$Water.visible = false
		return
	
	$Water.visible = true
	var water_radius := lerpf(radius, radius + height, water_level)
	var mesh_arrays := create_sphere(water_radius, water_detail)
	water.clear_surfaces()
	water.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, mesh_arrays)
	water.surface_set_material(0, water_material)

func update_collision() -> void:
	static_body = get_node_or_null("TerrainStaticBody")
	if not static_body:
		static_body = StaticBody3D.new()
		static_body.name = "TerrainStaticBody"
		static_body.set_collision_layer_value(2, true)
		add_child(static_body)
		if Engine.is_editor_hint():
			static_body.owner = get_tree().edited_scene_root
	
	collision_shape = static_body.get_node_or_null("TerrainCollisionShape")
	if not collision_shape:
		collision_shape = CollisionShape3D.new()
		collision_shape.name = "TerrainCollisionShape"
		static_body.add_child(collision_shape)
		if Engine.is_editor_hint():
			collision_shape.owner = get_tree().edited_scene_root
			
	var shape = terrain.create_trimesh_shape()
	collision_shape.shape = shape

func remove_collision() -> void:
	var body = get_node_or_null("TerrainStaticBody")
	if body:
		body.queue_free()
