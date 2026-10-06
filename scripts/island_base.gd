class_name IslandBase
extends Node3D

## Procedural island pedestal and ground collider supporting dynamic grid sizes (8x8, 12x12, 16x16, 20x20, 24x24)
## and toggleable 3D surface grid lines matching Three.js GridHelper.

@export var cell_size: float = 1.0

var _top_mesh: MeshInstance3D
var _bottom_mesh: MeshInstance3D
var _grid_lines_mesh: MeshInstance3D
var _static_body: StaticBody3D
var _collision_shape: CollisionShape3D

var _grid_lines_visible: bool = true

func _ready() -> void:
	_create_nodes()
	setup_grid(12)

func _create_nodes() -> void:
	if not _top_mesh:
		_top_mesh = MeshInstance3D.new()
		_top_mesh.name = "TopPedestal"
		add_child(_top_mesh)
	
	if not _bottom_mesh:
		_bottom_mesh = MeshInstance3D.new()
		_bottom_mesh.name = "BottomRockPedestal"
		add_child(_bottom_mesh)
	
	if not _grid_lines_mesh:
		_grid_lines_mesh = MeshInstance3D.new()
		_grid_lines_mesh.name = "GridLines"
		var line_mat = StandardMaterial3D.new()
		line_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		line_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		line_mat.albedo_color = Color(1.0, 1.0, 1.0, 0.35)
		line_mat.render_priority = 2
		_grid_lines_mesh.material_override = line_mat
		add_child(_grid_lines_mesh)
	
	if not _static_body:
		_static_body = StaticBody3D.new()
		_static_body.name = "GroundCollider"
		# Layer 1 for ground raycasting
		_static_body.collision_layer = 1
		_static_body.collision_mask = 0
		add_child(_static_body)
		
		_collision_shape = CollisionShape3D.new()
		_collision_shape.name = "CollisionShape"
		_static_body.add_child(_collision_shape)

func setup_grid(grid_size: int) -> void:
	_create_nodes()
	
	var island_width = float(grid_size) * cell_size
	var island_depth = float(grid_size) * cell_size
	
	# Top soil layer (Warm earth-brown)
	var top_box = BoxMesh.new()
	top_box.size = Vector3(island_width + 0.3, 0.3, island_depth + 0.3)
	top_box.material = Palette.create_material(Color("#5c4033"), 0.85, 0.05)
	_top_mesh.mesh = top_box
	_top_mesh.position = Vector3(0.0, -0.15, 0.0)
	
	# Bottom sub-surface stone/cliff layer (Dark earth)
	var bottom_box = BoxMesh.new()
	bottom_box.size = Vector3(island_width + 0.1, 0.6, island_depth + 0.1)
	bottom_box.material = Palette.create_material(Color("#3d2817"), 0.9, 0.05)
	_bottom_mesh.mesh = bottom_box
	_bottom_mesh.position = Vector3(0.0, -0.55, 0.0)
	
	# 3D Grid Lines Overlay (Matching Web Three.js GridHelper at y = 0.025)
	var imm = ImmediateMesh.new()
	imm.clear_surfaces()
	imm.surface_begin(Mesh.PRIMITIVE_LINES)
	var half: float = (float(grid_size) * cell_size) * 0.5
	var y_line: float = 0.025
	for i in range(grid_size + 1):
		var coord: float = float(i) * cell_size - half
		# Lines parallel to Z
		imm.surface_add_vertex(Vector3(coord, y_line, -half))
		imm.surface_add_vertex(Vector3(coord, y_line, half))
		# Lines parallel to X
		imm.surface_add_vertex(Vector3(-half, y_line, coord))
		imm.surface_add_vertex(Vector3(half, y_line, coord))
	imm.surface_end()
	_grid_lines_mesh.mesh = imm
	_grid_lines_mesh.visible = _grid_lines_visible
	
	# Physics collision box for raycasting placement
	var col_box = BoxShape3D.new()
	col_box.size = Vector3(island_width, 0.1, island_depth)
	_collision_shape.shape = col_box
	_collision_shape.position = Vector3(0.0, -0.05, 0.0)

func set_grid_lines_visible(val: bool) -> void:
	_grid_lines_visible = val
	if _grid_lines_mesh:
		_grid_lines_mesh.visible = val

func is_grid_lines_visible() -> bool:
	return _grid_lines_visible

func toggle_grid_lines() -> bool:
	set_grid_lines_visible(not _grid_lines_visible)
	return _grid_lines_visible
