class_name IslandBase
extends Node3D

## Builds the 3-layer tapered floating island pedestal and subtle grid overlay,
## matching grid.js `createIslandBase(width, depth)` and `THREE.GridHelper` 1:1.

@export var grid_size: int = 12:
	set(value):
		grid_size = clampi(value, 4, 32)
		if is_inside_tree():
			rebuild()

@export var show_grid_lines: bool = true:
	set(value):
		show_grid_lines = value
		if _grid_lines_instance:
			_grid_lines_instance.visible = show_grid_lines

var _top_soil_instance: MeshInstance3D
var _deep_earth_instance: MeshInstance3D
var _bedrock_instance: MeshInstance3D
var _grid_lines_instance: MeshInstance3D
var _collision_body: StaticBody3D
var _collision_shape: CollisionShape3D

func _ready() -> void:
	rebuild()

func rebuild() -> void:
	for child in get_children():
		child.queue_free()
	
	var w := float(grid_size)
	var d := float(grid_size)
	
	# 1. Top Soil Layer (Mutterboden) - grid.js lines 142-149
	# BoxGeometry(width + 0.3, 0.3, depth + 0.3) at y = -0.15, color 0x5c4033, roughness 0.9
	_top_soil_instance = MeshInstance3D.new()
	_top_soil_instance.name = "TopSoilMesh"
	var top_box := BoxMesh.new()
	top_box.size = Vector3(w + 0.3, 0.3, d + 0.3)
	var top_mat := StandardMaterial3D.new()
	top_mat.albedo_color = Color("#5c4033")
	top_mat.roughness = 0.9
	top_mat.metallic = 0.0
	top_mat.metallic_specular = 0.1
	top_box.material = top_mat
	_top_soil_instance.mesh = top_box
	_top_soil_instance.position = Vector3(0.0, -0.15, 0.0)
	add_child(_top_soil_instance)
	
	# 2. Deep Earth Layer (Erdreich) - grid.js lines 151-158
	# BoxGeometry(width + 0.15, 0.9, depth + 0.15) at y = -0.75, color 0x6d4c41, roughness 0.95
	_deep_earth_instance = MeshInstance3D.new()
	_deep_earth_instance.name = "DeepEarthMesh"
	var mid_box := BoxMesh.new()
	mid_box.size = Vector3(w + 0.15, 0.9, d + 0.15)
	var mid_mat := StandardMaterial3D.new()
	mid_mat.albedo_color = Color("#6d4c41")
	mid_mat.roughness = 0.95
	mid_mat.metallic = 0.0
	mid_mat.metallic_specular = 0.1
	mid_box.material = mid_mat
	_deep_earth_instance.mesh = mid_box
	_deep_earth_instance.position = Vector3(0.0, -0.75, 0.0)
	add_child(_deep_earth_instance)
	
	# 3. Bedrock / Rocky Bottom Layer (Fels-Boden, verjüngt nach unten) - grid.js lines 160-167
	# BoxGeometry(width - 0.4, 0.9, depth - 0.4) at y = -1.65, color 0x475569, roughness 1.0
	_bedrock_instance = MeshInstance3D.new()
	_bedrock_instance.name = "BedrockMesh"
	var bot_box := BoxMesh.new()
	bot_box.size = Vector3(w - 0.4, 0.9, d - 0.4)
	var bot_mat := StandardMaterial3D.new()
	bot_mat.albedo_color = Color("#475569")
	bot_mat.roughness = 1.0
	bot_mat.metallic = 0.0
	bot_mat.metallic_specular = 0.05
	bot_box.material = bot_mat
	_bedrock_instance.mesh = bot_box
	_bedrock_instance.position = Vector3(0.0, -1.65, 0.0)
	add_child(_bedrock_instance)
	
	# 4. Subtle Grid Lines (GridHelper) - grid.js lines 113-118
	# THREE.GridHelper(width, width, 0x334155, 0x475569) at y = 0.025, opacity 0.22
	_grid_lines_instance = MeshInstance3D.new()
	_grid_lines_instance.name = "GridLines"
	_grid_lines_instance.mesh = _build_grid_lines_mesh(grid_size)
	_grid_lines_instance.position = Vector3(0.0, 0.025, 0.0)
	_grid_lines_instance.visible = show_grid_lines
	_grid_lines_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(_grid_lines_instance)
	
	# 5. Raycast Collision Plane at y = 0
	_collision_body = StaticBody3D.new()
	_collision_body.name = "GridRaycastBody"
	_collision_shape = CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(w, 0.1, d)
	_collision_shape.shape = shape
	_collision_shape.position = Vector3(0.0, -0.05, 0.0)
	_collision_body.add_child(_collision_shape)
	add_child(_collision_body)

func _build_grid_lines_mesh(size: int) -> ImmediateMesh:
	var im := ImmediateMesh.new()
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color = Color(0.278, 0.333, 0.412, 0.25) # #475569 with 0.25 alpha
	
	var half := float(size) * 0.5
	im.surface_begin(Mesh.PRIMITIVE_LINES, mat)
	for i in range(size + 1):
		var offset := -half + float(i)
		im.surface_add_vertex(Vector3(offset, 0.0, -half))
		im.surface_add_vertex(Vector3(offset, 0.0, half))
		im.surface_add_vertex(Vector3(-half, 0.0, offset))
		im.surface_add_vertex(Vector3(half, 0.0, offset))
	im.surface_end()
	return im
