class_name ProceduralModels
extends RefCounted

## 1:1 Procedural 3D Model Factory ported from Modulon `models.js`.
## Builds all 42 low-poly diorama tiles, buildings, plants, creatures, and decorations
## directly in code with exact Three.js geometry, colors, and animation references.

static var _mat_cache: Dictionary = {}

static func _mat(hex: int, roughness: float = 0.75, metallic: float = 0.0, alpha: float = 1.0, emissive_hex: int = -1, emissive_energy: float = 0.0, unique: bool = false) -> StandardMaterial3D:
	var key := "%d_%.2f_%.2f_%.2f_%d_%.2f" % [hex, roughness, metallic, alpha, emissive_hex, emissive_energy]
	if not unique and _mat_cache.has(key):
		return _mat_cache[key]
	var m := StandardMaterial3D.new()
	var r := float((hex >> 16) & 0xFF) / 255.0
	var g := float((hex >> 8) & 0xFF) / 255.0
	var b := float(hex & 0xFF) / 255.0
	m.albedo_color = Color(r, g, b, alpha)
	m.roughness = roughness
	m.metallic = metallic
	m.metallic_specular = 0.12
	if alpha < 0.999:
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	if emissive_hex >= 0 and emissive_energy > 0.0:
		var er := float((emissive_hex >> 16) & 0xFF) / 255.0
		var eg := float((emissive_hex >> 8) & 0xFF) / 255.0
		var eb := float(emissive_hex & 0xFF) / 255.0
		m.emission_enabled = true
		m.emission = Color(er, eg, eb)
		m.emission_energy_multiplier = emissive_energy
	if not unique:
		_mat_cache[key] = m
	return m

static func _box(parent: Node3D, size: Vector3, mat: Material, pos: Vector3 = Vector3.ZERO, rot: Vector3 = Vector3.ZERO, cast_sh: bool = true) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = size
	bm.material = mat
	mi.mesh = bm
	mi.rotation_order = EULER_ORDER_XYZ
	mi.position = pos
	mi.rotation = rot
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON if cast_sh else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(mi)
	return mi

static func _cyl(parent: Node3D, r_top: float, r_bot: float, height: float, segs: int, mat: Material, pos: Vector3 = Vector3.ZERO, rot: Vector3 = Vector3.ZERO, cast_sh: bool = true) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = r_top
	cm.bottom_radius = r_bot
	cm.height = height
	cm.radial_segments = max(4, segs)
	cm.rings = 1
	cm.material = mat
	mi.mesh = cm
	mi.rotation_order = EULER_ORDER_XYZ
	mi.position = pos
	mi.rotation = rot
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON if cast_sh else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(mi)
	return mi

static func _cone(parent: Node3D, radius: float, height: float, segs: int, mat: Material, pos: Vector3 = Vector3.ZERO, rot: Vector3 = Vector3.ZERO, cast_sh: bool = true) -> MeshInstance3D:
	return _cyl(parent, 0.0, radius, height, segs, mat, pos, rot, cast_sh)

static func _sphere(parent: Node3D, radius: float, segs: int, mat: Material, pos: Vector3 = Vector3.ZERO, scale_vec: Vector3 = Vector3.ONE, cast_sh: bool = true) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = radius
	sm.height = radius * 2.0
	sm.radial_segments = max(4, segs)
	sm.rings = max(3, segs / 2)
	sm.material = mat
	mi.mesh = sm
	mi.rotation_order = EULER_ORDER_XYZ
	mi.position = pos
	mi.scale = scale_vec
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON if cast_sh else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(mi)
	return mi

static func _torus(parent: Node3D, outer_r: float, tube_r: float, mat: Material, pos: Vector3 = Vector3.ZERO, rot: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var tm := TorusMesh.new()
	tm.inner_radius = maxf(0.01, outer_r - tube_r)
	tm.outer_radius = outer_r + tube_r
	tm.rings = 16
	tm.ring_segments = 8
	tm.material = mat
	mi.mesh = tm
	mi.rotation_order = EULER_ORDER_XYZ
	mi.position = pos
	mi.rotation = rot
	parent.add_child(mi)
	return mi

static func _add_collider(root: Node3D, size: Vector3, center_y: float) -> void:
	var sb := StaticBody3D.new()
	sb.name = "PropCollider"
	var cs := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	cs.shape = shape
	cs.position = Vector3(0.0, center_y, 0.0)
	sb.add_child(cs)
	root.add_child(sb)

static func create_model(type_id: String) -> DioramaProp:
	var norm := Catalog.normalize_type(type_id)
	var root := DioramaProp.new()
	root.prop_type = norm
	root.name = "Prop_" + norm
	
	match norm:
		# --- 10 GROUND TILES ---
		"grass": _build_grass_tile(root)
		"water": _build_water_tile(root)
		"stone": _build_stone_tile(root)
		"wood": _build_wood_tile(root)
		"steppingstones": _build_stepping_stones_tile(root)
		"field_vegetable": _build_vegetable_field(root)
		"field_fruit": _build_fruit_field(root)
		"field_mushroom": _build_mushroom_field(root)
		"field_flower": _build_flower_field(root)
		"field_orchard": _build_orchard_field(root)
		
		# --- 3 BUILDINGS ---
		"cottage": _build_cottage(root)
		"townhouse": _build_townhouse(root)
		"apartment": _build_apartment(root)
		
		# --- 12 NATURE ITEMS ---
		"tree": _build_leafy_tree(root)
		"pine": _build_pine_tree(root)
		"pond": _build_pond(root)
		"bush": _build_bush(root)
		"flowerpot": _build_flower_pot(root)
		"claypot": _build_clay_pot(root)
		"sunflower": _build_sunflower(root)
		"cactus": _build_cactus(root)
		"flyagaric": _build_fly_agaric(root)
		"mushrooms": _build_mushroom_cluster(root)
		"strawberry_plant": _build_strawberry_plant(root)
		"potato_plant": _build_potato_plant(root)
		
		# --- 12 CREATURES ---
		"human": _build_human(root)
		"cat": _build_cat(root)
		"dog": _build_dog(root)
		"duck": _build_duck(root)
		"squirrel": _build_squirrel(root)
		"axolotl": _build_axolotl(root)
		"pig": _build_pig(root)
		"parrot": _build_parrot(root)
		"horse": _build_horse(root)
		"elephant": _build_elephant(root)
		"lion": _build_lion(root)
		"whitetiger": _build_white_tiger(root)
		
		# --- 5 DECO ITEMS ---
		"streetlamp": _build_streetlamp(root)
		"bench": _build_bench(root)
		"fountain": _build_fountain(root)
		"fence": _build_fence(root)
		"beertable": _build_beer_table(root)
		_:
			_build_grass_tile(root)
	return root

# =============================================================================
# 1. GROUND TILES (10)
# =============================================================================

static func _build_grass_tile(root: DioramaProp) -> void:
	root.is_ground = true
	_box(root, Vector3(0.99, 0.22, 0.99), _mat(0x389e63, 0.85), Vector3(0.0, -0.09, 0.0), Vector3.ZERO, false)
	var blade_light := _mat(0x68d391, 0.7)
	var blade_dark := _mat(0x276749, 0.75)
	var tuft_positions := [
		[-0.30, -0.28, 0.2], [0.28, -0.32, 1.1],
		[-0.24, 0.26, 2.4], [0.32, 0.22, 3.8],
		[0.04, -0.05, 0.9],
	]
	for t in tuft_positions:
		var tx: float = t[0]
		var tz: float = t[1]
		var rot: float = t[2]
		var tuft := Node3D.new()
		tuft.position = Vector3(tx, 0.02, tz)
		tuft.rotation.y = rot
		root.add_child(tuft)
		_cone(tuft, 0.032, 0.14, 4, blade_light, Vector3(0.0, 0.06, 0.0), Vector3(0.08, 0.0, -0.08))
		_cone(tuft, 0.028, 0.11, 4, blade_dark, Vector3(0.035, 0.045, 0.02), Vector3(-0.18, 0.0, -0.25))
		_cone(tuft, 0.028, 0.12, 4, blade_light, Vector3(-0.035, 0.05, -0.02), Vector3(0.22, 0.0, 0.25))
	# Tiny wild daisy flower
	_cyl(root, 0.01, 0.01, 0.06, 4, blade_dark, Vector3(-0.18, 0.05, -0.15), Vector3.ZERO, false)
	_cyl(root, 0.04, 0.04, 0.015, 6, _mat(0xffffff, 0.5), Vector3(-0.18, 0.08, -0.15), Vector3.ZERO, false)
	_sphere(root, 0.018, 5, _mat(0xfacc15, 0.4), Vector3(-0.18, 0.09, -0.15), Vector3.ONE, false)

static func _build_water_tile(root: DioramaProp) -> void:
	root.is_ground = true
	_box(root, Vector3(0.99, 0.18, 0.99), _mat(0x0284c7, 0.5), Vector3(0.0, -0.11, 0.0), Vector3.ZERO, false)
	var water_surf := _box(root, Vector3(0.99, 0.04, 0.99), _mat(0x0284c7, 0.12, 0.05), Vector3(0.0, 0.0, 0.0), Vector3.ZERO, false)
	root.refs["water_surface"] = water_surf
	var ripple_mat := _mat(0xffffff, 0.2)
	var ripple_defs := [
		[-0.22, -0.22, 0.26, 0.04, 0.15],
		[0.20, 0.06, 0.30, 0.04, -0.22],
		[-0.12, 0.26, 0.22, 0.035, 0.12],
		[0.18, -0.28, 0.18, 0.035, -0.14],
	]
	var ripples: Array = []
	for rd in ripple_defs:
		var rp := _box(root, Vector3(rd[2], 0.008, rd[3]), ripple_mat, Vector3(rd[0], 0.026, rd[1]), Vector3(0.0, rd[4], 0.0), false)
		ripples.append(rp)
	root.refs["ripples"] = ripples

static func _build_stone_tile(root: DioramaProp) -> void:
	root.is_ground = true
	_box(root, Vector3(0.99, 0.22, 0.99), _mat(0x8b5a2b, 0.9), Vector3(0.0, -0.09, 0.0), Vector3.ZERO, false)
	var s1 := _mat(0x9ca3af, 0.85)
	var s2 := _mat(0x6b7280, 0.9)
	var offsets := [[-0.22, -0.22], [0.22, -0.20], [-0.20, 0.22], [0.22, 0.22], [0.0, 0.0]]
	for i in range(offsets.size()):
		var ox: float = offsets[i][0]
		var oz: float = offsets[i][1]
		var sz := 0.25 if i == 4 else 0.36
		_box(root, Vector3(sz, 0.07, sz), s1 if i % 2 == 0 else s2, Vector3(ox, 0.04, oz), Vector3(0.0, float(i) * 0.15, 0.0), false)

static func _build_wood_tile(root: DioramaProp) -> void:
	root.is_ground = true
	_box(root, Vector3(0.99, 0.20, 0.99), _mat(0x8a5d3b, 0.85), Vector3(0.0, -0.10, 0.0), Vector3.ZERO, false)
	var p1 := _mat(0xb48455, 0.75)
	var p2 := _mat(0xd4a373, 0.75)
	for i in range(4):
		_box(root, Vector3(0.22, 0.04, 0.96), p1 if i % 2 == 0 else p2, Vector3(-0.36 + float(i) * 0.24, 0.02, 0.0), Vector3.ZERO, false)

static func _build_stepping_stones_tile(root: DioramaProp) -> void:
	root.is_ground = true
	_box(root, Vector3(0.99, 0.22, 0.99), _mat(0x389e63, 0.85), Vector3(0.0, -0.09, 0.0), Vector3.ZERO, false)
	var mats := [_mat(0x9ca3af, 0.85), _mat(0x6b7280, 0.9), _mat(0xcbd5e1, 0.8)]
	var stones := [
		[-0.22, -0.32, 0.15, 0.17, 6, 0.2, 0],
		[0.14, -0.16, 0.17, 0.19, 7, 0.8, 1],
		[-0.12, 0.06, 0.18, 0.20, 6, 1.4, 2],
		[0.20, 0.24, 0.15, 0.17, 6, 2.1, 0],
		[-0.28, 0.30, 0.09, 0.11, 5, 0.5, 1],
		[0.30, -0.34, 0.08, 0.10, 5, 1.9, 2],
	]
	for st in stones:
		_cyl(root, st[2], st[3], 0.045, int(st[4]), mats[int(st[6])], Vector3(st[0], 0.035, st[1]), Vector3(0.0, st[5], 0.0), false)

static func _build_vegetable_field(root: DioramaProp) -> void:
	root.is_ground = true
	root.is_field = true
	root.field_type = "vegetable"
	_box(root, Vector3(0.99, 0.22, 0.99), _mat(0x5c3a1d, 0.9), Vector3(0.0, -0.09, 0.0), Vector3.ZERO, false)
	var ridge_mat := _mat(0x452a17, 0.95)
	for rx in [-0.28, 0.0, 0.28]:
		_box(root, Vector3(0.20, 0.05, 0.94), ridge_mat, Vector3(rx, 0.045, 0.0), Vector3.ZERO, false)

static func _build_fruit_field(root: DioramaProp) -> void:
	root.is_ground = true
	root.is_field = true
	root.field_type = "fruit"
	_box(root, Vector3(0.99, 0.22, 0.99), _mat(0x6b4423, 0.85), Vector3(0.0, -0.09, 0.0), Vector3.ZERO, false)
	_box(root, Vector3(0.92, 0.03, 0.92), _mat(0x8a5d3b, 0.9), Vector3(0.0, 0.035, 0.0), Vector3.ZERO, false)
	var border_mat := _mat(0x5c3a1d, 0.8)
	for px in [-0.47, 0.47]:
		_box(root, Vector3(0.05, 0.06, 0.96), border_mat, Vector3(px, 0.05, 0.0), Vector3.ZERO, false)
	for pz in [-0.47, 0.47]:
		_box(root, Vector3(0.88, 0.06, 0.05), border_mat, Vector3(0.0, 0.05, pz), Vector3.ZERO, false)

static func _build_mushroom_field(root: DioramaProp) -> void:
	root.is_ground = true
	root.is_field = true
	root.field_type = "mushroom"
	_box(root, Vector3(0.99, 0.22, 0.99), _mat(0x3f2d1e, 0.95), Vector3(0.0, -0.09, 0.0), Vector3.ZERO, false)
	var moss_mat := _mat(0x3f6212, 0.9)
	for mp in [[-0.25, -0.20, 0.18], [0.22, 0.18, 0.16], [-0.15, 0.26, 0.14]]:
		_cyl(root, mp[2], mp[2] * 1.1, 0.025, 6, moss_mat, Vector3(mp[0], 0.03, mp[1]), Vector3.ZERO, false)
	_cyl(root, 0.04, 0.045, 0.36, 5, _mat(0x5c3a1d, 0.9), Vector3(0.18, 0.04, -0.22), Vector3(0.0, 0.4, PI * 0.5), false)

static func _build_flower_field(root: DioramaProp) -> void:
	root.is_ground = true
	root.is_field = true
	root.field_type = "flower"
	_box(root, Vector3(0.99, 0.22, 0.99), _mat(0x4a2f18, 0.9), Vector3(0.0, -0.09, 0.0), Vector3.ZERO, false)
	var brick_mat := _mat(0xb45309, 0.75)
	for i in range(-3, 4):
		_box(root, Vector3(0.12, 0.05, 0.06), brick_mat, Vector3(float(i) * 0.135, 0.045, -0.45), Vector3.ZERO, false)
		_box(root, Vector3(0.12, 0.05, 0.06), brick_mat, Vector3(float(i) * 0.135, 0.045, 0.45), Vector3.ZERO, false)
	for i in range(-2, 3):
		_box(root, Vector3(0.06, 0.05, 0.12), brick_mat, Vector3(-0.45, 0.045, float(i) * 0.15), Vector3.ZERO, false)
		_box(root, Vector3(0.06, 0.05, 0.12), brick_mat, Vector3(0.45, 0.045, float(i) * 0.15), Vector3.ZERO, false)

static func _build_orchard_field(root: DioramaProp) -> void:
	root.is_ground = true
	root.is_field = true
	root.field_type = "orchard"
	_box(root, Vector3(0.99, 0.22, 0.99), _mat(0x65a30d, 0.85), Vector3(0.0, -0.09, 0.0), Vector3.ZERO, false)
	_cyl(root, 0.34, 0.36, 0.02, 8, _mat(0x78350f, 0.9), Vector3(0.0, 0.03, 0.0), Vector3.ZERO, false)
	var leaf1 := _mat(0xd97706, 0.8)
	var leaf2 := _mat(0xb45309, 0.8)
	var lp := [[-0.28, -0.25, 0], [0.30, -0.20, 1], [-0.22, 0.28, 1], [0.26, 0.26, 0]]
	for l in lp:
		_box(root, Vector3(0.08, 0.015, 0.06), leaf1 if int(l[2]) == 0 else leaf2, Vector3(l[0], 0.032, l[1]), Vector3(0.0, float(l[0]) * 3.0, 0.0), false)

# =============================================================================
# 2. BUILDINGS (3)
# =============================================================================

static func _build_cottage(root: DioramaProp) -> void:
	root.is_interactable = true
	_add_collider(root, Vector3(1.6, 1.8, 1.4), 0.9)
	# 1. Stone foundation (2x2 footprint)
	_box(root, Vector3(1.75, 0.18, 1.55), _mat(0x94a3b8, 0.9), Vector3(0.0, 0.09, 0.0))
	# 2. Cream walls
	_box(root, Vector3(1.6, 1.0, 1.4), _mat(0xfffbeb, 0.85), Vector3(0.0, 0.65, 0.0))
	# Corner timber beams
	var timber_mat := _mat(0x5c3a21, 0.85)
	for cx in [-0.78, 0.78]:
		for cz in [-0.68, 0.68]:
			_box(root, Vector3(0.08, 1.02, 0.08), timber_mat, Vector3(cx, 0.65, cz))
	# 3. Terracotta hipped/gabled roof (4-sided cone + roof trim peak)
	var roof_mat := _mat(0xe05a47, 0.65)
	_cone(root, 1.35, 0.8, 4, roof_mat, Vector3(0.0, 1.55, 0.0), Vector3(0.0, PI * 0.25, 0.0))
	_box(root, Vector3(1.7, 0.1, 0.12), _mat(0x7c2d12, 0.8), Vector3(0.0, 1.9, 0.0))
	# 4. Chimney + cap
	_box(root, Vector3(0.24, 0.55, 0.24), _mat(0x64748b, 0.9), Vector3(0.45, 1.58, -0.35))
	_box(root, Vector3(0.30, 0.06, 0.30), _mat(0x475569, 0.9), Vector3(0.45, 1.86, -0.35))
	# 5. Wooden front door + step + brass knob
	_box(root, Vector3(0.34, 0.58, 0.06), _mat(0x7c3f1d, 0.8), Vector3(0.0, 0.44, 0.71))
	_box(root, Vector3(0.48, 0.08, 0.22), _mat(0x64748b, 0.9), Vector3(0.0, 0.12, 0.80))
	_sphere(root, 0.03, 6, _mat(0xfbbf24, 0.3, 0.6), Vector3(0.11, 0.42, 0.75))
	# 6. Windows (front left/right + side left/right)
	var glass_mat := _mat(0xbae6fd, 0.15, 0.1, 1.0, 0xfef08a, 0.25)
	var frame_mat := _mat(0x78350f, 0.8)
	for wx in [-0.48, 0.48]:
		var wg := Node3D.new()
		wg.position = Vector3(wx, 0.72, 0.71)
		root.add_child(wg)
		_box(wg, Vector3(0.34, 0.34, 0.04), frame_mat)
		_box(wg, Vector3(0.26, 0.26, 0.06), glass_mat)
		_box(wg, Vector3(0.38, 0.05, 0.10), frame_mat, Vector3(0.0, -0.18, 0.03))
	for sx in [-0.81, 0.81]:
		var sw := Node3D.new()
		sw.position = Vector3(sx, 0.72, 0.0)
		sw.rotation.y = PI * 0.5
		root.add_child(sw)
		_box(sw, Vector3(0.34, 0.34, 0.04), frame_mat)
		_box(sw, Vector3(0.26, 0.26, 0.06), glass_mat)

static func _build_townhouse(root: DioramaProp) -> void:
	root.is_interactable = true
	_add_collider(root, Vector3(1.6, 2.2, 1.5), 1.1)
	var plinth_mat := _mat(0x94a3b8, 0.85)
	var wall_mat := _mat(0xfde68a, 0.8)
	var belt_mat := _mat(0xfef3c7, 0.7)
	var roof_mat := _mat(0x334155, 0.6)
	var win_frame := _mat(0xffffff, 0.6)
	var win_glass := _mat(0x93c5fd, 0.15, 0.1, 1.0, 0xfef08a, 0.2)
	
	_box(root, Vector3(1.68, 0.18, 1.48), plinth_mat, Vector3(0.0, 0.09, 0.0))
	_box(root, Vector3(1.6, 1.75, 1.4), wall_mat, Vector3(0.0, 0.98, 0.0))
	_box(root, Vector3(1.66, 0.08, 1.46), belt_mat, Vector3(0.0, 0.98, 0.0))
	_box(root, Vector3(1.70, 0.12, 1.50), belt_mat, Vector3(0.0, 1.88, 0.0))
	_cone(root, 1.25, 0.65, 4, roof_mat, Vector3(0.0, 2.26, 0.0), Vector3(0.0, PI * 0.25, 0.0))
	# Front door + canopy + steps
	_box(root, Vector3(0.34, 0.62, 0.06), _mat(0x1e3a8a, 0.6), Vector3(-0.38, 0.46, 0.71))
	_box(root, Vector3(0.46, 0.06, 0.22), belt_mat, Vector3(-0.38, 0.82, 0.78))
	_box(root, Vector3(0.46, 0.12, 0.22), plinth_mat, Vector3(-0.38, 0.10, 0.78))
	# Ground floor windows
	for wx in [0.12, 0.52]:
		_box(root, Vector3(0.28, 0.38, 0.04), win_frame, Vector3(wx, 0.56, 0.71))
		_box(root, Vector3(0.22, 0.30, 0.06), win_glass, Vector3(wx, 0.56, 0.71))
	# Upper floor 3 windows
	for wx in [-0.46, 0.0, 0.46]:
		_box(root, Vector3(0.30, 0.40, 0.04), win_frame, Vector3(wx, 1.42, 0.71))
		_box(root, Vector3(0.22, 0.32, 0.06), win_glass, Vector3(wx, 1.42, 0.71))
	# Dynamic connection wings (N, E, S, W) for seamless row houses
	var dirs := {"n": Vector3(0, 0, -0.82), "s": Vector3(0, 0, 0.82), "e": Vector3(0.86, 0, 0), "w": Vector3(-0.86, 0, 0)}
	for d_key in dirs:
		var wing := Node3D.new()
		wing.visible = false
		root.add_child(wing)
		var p: Vector3 = dirs[d_key]
		var sz := Vector3(0.32, 1.75, 1.38) if d_key in ["e", "w"] else Vector3(1.58, 1.75, 0.36)
		var r_sz := Vector3(0.36, 0.35, 1.42) if d_key in ["e", "w"] else Vector3(1.62, 0.35, 0.40)
		_box(wing, sz, wall_mat, Vector3(p.x, 0.98, p.z))
		_box(wing, r_sz, roof_mat, Vector3(p.x, 2.02, p.z))
		root.refs["ext_" + d_key] = wing

static func _build_apartment(root: DioramaProp) -> void:
	root.is_interactable = true
	_add_collider(root, Vector3(1.68, 2.7, 1.52), 1.35)
	var base_mat := _mat(0x64748b, 0.85)
	var wall_mat := _mat(0xe2e8f0, 0.75)
	var accent_mat := _mat(0xcbd5e1, 0.8)
	var roof_mat := _mat(0x334155, 0.8)
	var glass_mat := _mat(0x38bdf8, 0.15, 0.2, 1.0, 0xfef08a, 0.18)
	var frame_mat := _mat(0x1e293b, 0.6)
	
	_box(root, Vector3(1.72, 0.20, 1.56), base_mat, Vector3(0.0, 0.10, 0.0))
	_box(root, Vector3(1.66, 2.40, 1.48), wall_mat, Vector3(0.0, 1.35, 0.0))
	for fy in [0.90, 1.70, 2.55]:
		_box(root, Vector3(1.70, 0.07, 1.52), accent_mat, Vector3(0.0, fy, 0.0))
	_box(root, Vector3(1.54, 0.08, 1.36), roof_mat, Vector3(0.0, 2.60, 0.0))
	_box(root, Vector3(0.45, 0.25, 0.45), base_mat, Vector3(0.35, 2.74, -0.20))
	# Glass entrance lobby
	_box(root, Vector3(0.46, 0.62, 0.06), frame_mat, Vector3(0.0, 0.46, 0.75))
	_box(root, Vector3(0.38, 0.56, 0.08), glass_mat, Vector3(0.0, 0.46, 0.75))
	# 3 floors of windows + balconies
	for floor_idx in range(3):
		var wy := 0.52 + float(floor_idx) * 0.80
		for wx in [-0.50, 0.0, 0.50]:
			if floor_idx == 0 and wx == 0.0:
				continue
			_box(root, Vector3(0.32, 0.42, 0.04), frame_mat, Vector3(wx, wy, 0.75))
			_box(root, Vector3(0.26, 0.34, 0.06), glass_mat, Vector3(wx, wy, 0.75))
		if floor_idx > 0:
			_box(root, Vector3(0.44, 0.05, 0.20), accent_mat, Vector3(0.0, wy - 0.20, 0.84))
			_box(root, Vector3(0.42, 0.16, 0.03), glass_mat, Vector3(0.0, wy - 0.10, 0.92))
	# Dynamic connection wings (N, E, S, W)
	var dirs := {"n": Vector3(0, 0, -0.80), "s": Vector3(0, 0, 0.80), "e": Vector3(0.86, 0, 0), "w": Vector3(-0.86, 0, 0)}
	for d_key in dirs:
		var wing := Node3D.new()
		wing.visible = false
		root.add_child(wing)
		var p: Vector3 = dirs[d_key]
		var sz := Vector3(0.30, 2.40, 1.44) if d_key in ["e", "w"] else Vector3(1.62, 2.40, 0.32)
		_box(wing, sz, wall_mat, Vector3(p.x, 1.35, p.z))
		root.refs["ext_" + d_key] = wing

# =============================================================================
# 3. NATURE ITEMS (12)
# =============================================================================

static func _build_leafy_tree(root: DioramaProp) -> void:
	root.is_interactable = true
	_add_collider(root, Vector3(0.85, 1.65, 0.85), 0.82)
	var trunk_mat := _mat(0x7c4a21, 0.9)
	_cyl(root, 0.09, 0.15, 0.75, 7, trunk_mat, Vector3(0.0, 0.375, 0.0))
	# Prominent side branch for perching parrots & squirrels
	_cyl(root, 0.035, 0.055, 0.32, 5, trunk_mat, Vector3(0.14, 0.58, 0.05), Vector3(0.0, 0.0, -0.95))
	# 6-sphere organic canopy cluster
	var m1 := _mat(0x22c55e, 0.75)
	var m2 := _mat(0x16a34a, 0.8)
	var m3 := _mat(0x4ade80, 0.7)
	_sphere(root, 0.38, 8, m1, Vector3(0.0, 0.98, 0.0))
	_sphere(root, 0.28, 7, m2, Vector3(-0.20, 0.88, 0.14))
	_sphere(root, 0.27, 7, m2, Vector3(0.22, 0.90, -0.12))
	_sphere(root, 0.25, 7, m3, Vector3(0.12, 1.22, 0.10))
	_sphere(root, 0.24, 7, m1, Vector3(-0.14, 1.15, -0.15))
	_sphere(root, 0.22, 6, m3, Vector3(0.0, 1.34, 0.0))

static func _build_pine_tree(root: DioramaProp) -> void:
	root.is_interactable = true
	_add_collider(root, Vector3(0.85, 1.75, 0.85), 0.88)
	_cyl(root, 0.08, 0.12, 0.45, 7, _mat(0x5c3a21, 0.9), Vector3(0.0, 0.225, 0.0))
	var dark_pine := _mat(0x2d6a4f, 0.8)
	var light_pine := _mat(0x40916c, 0.8)
	_cone(root, 0.46, 0.65, 7, dark_pine, Vector3(0.0, 0.68, 0.0))
	_cone(root, 0.36, 0.58, 7, light_pine, Vector3(0.0, 1.06, 0.0))
	_cone(root, 0.25, 0.50, 7, dark_pine, Vector3(0.0, 1.40, 0.0))

static func _build_pond(root: DioramaProp) -> void:
	root.is_interactable = true
	_add_collider(root, Vector3(1.85, 0.35, 1.85), 0.15)
	_cyl(root, 0.88, 0.92, 0.07, 16, _mat(0x475569, 0.95), Vector3(0.0, 0.01, 0.0))
	var water_surf := _cyl(root, 0.78, 0.78, 0.05, 16, _mat(0x0284c7, 0.12, 0.08), Vector3(0.0, 0.03, 0.0))
	root.refs["water_surface"] = water_surf
	var r1 := _mat(0x94a3b8, 0.85)
	var r2 := _mat(0x64748b, 0.9)
	for i in range(14):
		var angle := (float(i) / 14.0) * TAU
		var radius := 0.76 + (0.04 if i % 2 == 0 else -0.02)
		var rx := cos(angle) * radius
		var rz := sin(angle) * radius
		var r_size := 0.12 + float(i % 3) * 0.025
		_sphere(root, r_size, 6, r1 if i % 2 == 0 else r2, Vector3(rx, 0.05, rz), Vector3(1.2, 0.65, 1.0))
	var lily := Node3D.new()
	lily.position = Vector3(-0.22, 0.042, 0.16)
	root.add_child(lily)
	_cyl(lily, 0.15, 0.15, 0.015, 10, _mat(0x22c55e, 0.7))
	_sphere(lily, 0.055, 6, _mat(0xf472b6, 0.5), Vector3(0.02, 0.03, 0.0))
	root.refs["lily"] = lily
	# Reeds / cattails
	var reed_mat := _mat(0x15803d, 0.8)
	var cat_mat := _mat(0x5c3a21, 0.9)
	for rp in [[0.52, -0.45, 0.38], [0.60, -0.34, 0.30]]:
		_cyl(root, 0.015, 0.02, rp[2], 5, reed_mat, Vector3(rp[0], rp[2] * 0.5, rp[1]))
		_cyl(root, 0.028, 0.028, 0.09, 5, cat_mat, Vector3(rp[0], rp[2] - 0.04, rp[1]))

static func _build_bush(root: DioramaProp) -> void:
	root.is_interactable = true
	_add_collider(root, Vector3(0.65, 0.55, 0.65), 0.25)
	_sphere(root, 0.26, 7, _mat(0x16a34a, 0.8), Vector3(0.0, 0.22, 0.0))
	_sphere(root, 0.20, 7, _mat(0x22c55e, 0.75), Vector3(-0.15, 0.18, 0.10))
	_sphere(root, 0.19, 7, _mat(0x4ade80, 0.75), Vector3(0.16, 0.19, -0.08))
	var berry_mat := _mat(0xef4444, 0.4)
	for bp in [[0.10, 0.36, 0.18], [-0.14, 0.28, 0.20], [0.18, 0.26, 0.08], [-0.05, 0.40, -0.12]]:
		_sphere(root, 0.035, 5, berry_mat, Vector3(bp[0], bp[1], bp[2]))

static func _build_flower_pot(root: DioramaProp) -> void:
	root.is_interactable = true
	_add_collider(root, Vector3(0.45, 0.55, 0.45), 0.28)
	var pot_mat := _mat(0xc2410c, 0.75)
	_cyl(root, 0.16, 0.11, 0.22, 8, pot_mat, Vector3(0.0, 0.11, 0.0))
	_cyl(root, 0.18, 0.17, 0.04, 8, pot_mat, Vector3(0.0, 0.21, 0.0))
	_cyl(root, 0.15, 0.15, 0.02, 8, _mat(0x451a03, 0.95), Vector3(0.0, 0.22, 0.0))
	var stem_mat := _mat(0x16a34a, 0.8)
	var tulips := [[-0.05, -0.03, 0.18, 0xf43f5e], [0.06, -0.02, 0.21, 0xfacc15], [0.0, 0.06, 0.16, 0xa855f7]]
	for tl in tulips:
		var h: float = tl[2]
		_cyl(root, 0.012, 0.015, h, 5, stem_mat, Vector3(tl[0], 0.22 + h * 0.5, tl[1]))
		_sphere(root, 0.045, 6, _mat(int(tl[3]), 0.4), Vector3(tl[0], 0.22 + h + 0.02, tl[1]), Vector3(0.9, 1.25, 0.9))

static func _build_clay_pot(root: DioramaProp) -> void:
	root.is_interactable = true
	_add_collider(root, Vector3(0.55, 0.65, 0.55), 0.32)
	var terra_mat := _mat(0xd97706, 0.75)
	var rim_mat := _mat(0xb45309, 0.8)
	_cyl(root, 0.22, 0.15, 0.28, 10, terra_mat, Vector3(0.0, 0.14, 0.0))
	_cyl(root, 0.24, 0.23, 0.05, 10, rim_mat, Vector3(0.0, 0.265, 0.0))
	_cyl(root, 0.20, 0.20, 0.02, 10, _mat(0x3f2d1e, 0.95), Vector3(0.0, 0.28, 0.0))
	var leaf_mat := _mat(0x15803d, 0.75)
	for i in range(8):
		var a := (float(i) / 8.0) * TAU
		_sphere(root, 0.075, 6, leaf_mat, Vector3(cos(a) * 0.10, 0.32, sin(a) * 0.10), Vector3(1.1, 0.7, 1.1))
	var bloom_mat := _mat(0xef4444, 0.4)
	for bp in [[-0.06, 0.42, -0.04], [0.07, 0.44, 0.03], [0.0, 0.40, 0.08]]:
		_sphere(root, 0.055, 6, bloom_mat, Vector3(bp[0], bp[1], bp[2]))

static func _build_sunflower(root: DioramaProp) -> void:
	root.is_interactable = true
	_add_collider(root, Vector3(0.45, 0.95, 0.45), 0.48)
	var stem_mat := _mat(0x15803d, 0.8)
	_cyl(root, 0.022, 0.03, 0.72, 6, stem_mat, Vector3(0.0, 0.36, 0.0))
	_sphere(root, 0.07, 5, stem_mat, Vector3(-0.08, 0.32, 0.0), Vector3(1.5, 0.3, 0.8))
	_sphere(root, 0.07, 5, stem_mat, Vector3(0.08, 0.46, 0.0), Vector3(1.5, 0.3, 0.8))
	var head := Node3D.new()
	head.position = Vector3(0.0, 0.74, 0.04)
	head.rotation.x = 0.25
	root.add_child(head)
	_cyl(head, 0.09, 0.09, 0.04, 10, _mat(0x451a03, 0.9), Vector3.ZERO, Vector3(PI * 0.5, 0.0, 0.0))
	var petal_mat := _mat(0xfacc15, 0.4)
	for i in range(12):
		var a := (float(i) / 12.0) * TAU
		_box(head, Vector3(0.045, 0.09, 0.015), petal_mat, Vector3(cos(a) * 0.11, sin(a) * 0.11, 0.0), Vector3(0.0, 0.0, a - PI * 0.5))

static func _build_cactus(root: DioramaProp) -> void:
	root.is_interactable = true
	_add_collider(root, Vector3(0.55, 0.95, 0.45), 0.48)
	var cac_mat := _mat(0x16a34a, 0.75)
	_cyl(root, 0.10, 0.12, 0.76, 8, cac_mat, Vector3(0.0, 0.38, 0.0))
	_sphere(root, 0.10, 8, cac_mat, Vector3(0.0, 0.76, 0.0))
	# Left arm
	_cyl(root, 0.06, 0.06, 0.18, 7, cac_mat, Vector3(-0.14, 0.42, 0.0), Vector3(0.0, 0.0, PI * 0.5))
	_cyl(root, 0.06, 0.06, 0.24, 7, cac_mat, Vector3(-0.22, 0.54, 0.0))
	_sphere(root, 0.06, 7, cac_mat, Vector3(-0.22, 0.66, 0.0))
	# Right arm
	_cyl(root, 0.055, 0.055, 0.16, 7, cac_mat, Vector3(0.13, 0.50, 0.0), Vector3(0.0, 0.0, -PI * 0.5))
	_cyl(root, 0.055, 0.055, 0.20, 7, cac_mat, Vector3(0.20, 0.60, 0.0))
	_sphere(root, 0.055, 7, cac_mat, Vector3(0.20, 0.70, 0.0))
	# Pink desert flower on top
	_sphere(root, 0.045, 6, _mat(0xf43f5e, 0.4), Vector3(0.0, 0.87, 0.0), Vector3(1.2, 0.7, 1.2))

static func _build_fly_agaric(root: DioramaProp) -> void:
	root.is_interactable = true
	_add_collider(root, Vector3(0.55, 0.45, 0.55), 0.22)
	var stem_mat := _mat(0xfef3c7, 0.8)
	var cap_mat := _mat(0xdc2626, 0.45)
	var dot_mat := _mat(0xffffff, 0.5)
	var shrooms := [[0.0, 0.0, 0.24, 0.16], [-0.16, 0.12, 0.16, 0.11], [0.15, -0.10, 0.14, 0.095]]
	for sh in shrooms:
		var sx: float = sh[0]
		var sz: float = sh[1]
		var h: float = sh[2]
		var r: float = sh[3]
		_cyl(root, r * 0.28, r * 0.36, h, 7, stem_mat, Vector3(sx, h * 0.5, sz))
		_cone(root, r, r * 0.75, 9, cap_mat, Vector3(sx, h + r * 0.25, sz))
		# White spots on red cap
		for d in range(4):
			var da := (float(d) / 4.0) * TAU + 0.3
			_sphere(root, r * 0.16, 5, dot_mat, Vector3(sx + cos(da) * r * 0.52, h + r * 0.32, sz + sin(da) * r * 0.52))

static func _build_mushroom_cluster(root: DioramaProp) -> void:
	root.is_interactable = true
	root.harvest_yield = "mushroom"
	_add_collider(root, Vector3(0.55, 0.42, 0.55), 0.20)
	var stem_mat := _mat(0xf5f5f4, 0.85)
	var cap_dark := _mat(0x78350f, 0.75)
	var cap_light := _mat(0xa16207, 0.75)
	var hg := Node3D.new()
	root.add_child(hg)
	root.refs["harvest_group"] = hg
	var spots := [
		[0.0, 0.0, 0.20, 0.12, 0],
		[-0.15, 0.10, 0.15, 0.095, 1],
		[0.14, 0.12, 0.14, 0.09, 0],
		[-0.10, -0.14, 0.13, 0.085, 1],
		[0.16, -0.11, 0.11, 0.075, 0],
	]
	for sp in spots:
		var h: float = sp[2]
		var r: float = sp[3]
		_cyl(hg, r * 0.32, r * 0.38, h, 7, stem_mat, Vector3(sp[0], h * 0.5, sp[1]))
		_sphere(hg, r, 8, cap_dark if int(sp[4]) == 0 else cap_light, Vector3(sp[0], h, sp[1]), Vector3(1.0, 0.65, 1.0))

static func _build_strawberry_plant(root: DioramaProp) -> void:
	root.is_interactable = true
	root.harvest_yield = "strawberry"
	_add_collider(root, Vector3(0.58, 0.42, 0.58), 0.20)
	var leaf_mat := _mat(0x16a34a, 0.75)
	var leaf_light := _mat(0x22c55e, 0.75)
	for i in range(7):
		var a := (float(i) / 7.0) * TAU
		var r := 0.13 if i % 2 == 0 else 0.17
		_sphere(root, 0.095, 6, leaf_mat if i % 2 == 0 else leaf_light, Vector3(cos(a) * r, 0.11, sin(a) * r), Vector3(1.2, 0.55, 1.2))
	_sphere(root, 0.11, 6, leaf_light, Vector3(0.0, 0.15, 0.0), Vector3(1.1, 0.65, 1.1))
	# Harvestable red strawberries & white blossoms
	var hg := Node3D.new()
	root.add_child(hg)
	root.refs["harvest_group"] = hg
	var berry_mat := _mat(0xef4444, 0.35)
	var berries := [[-0.14, 0.12, 0.12], [0.15, 0.11, 0.10], [0.02, 0.14, -0.15], [-0.11, 0.13, -0.10], [0.12, 0.15, -0.06]]
	for bp in berries:
		_cone(hg, 0.038, 0.065, 6, berry_mat, Vector3(bp[0], bp[1], bp[2]), Vector3(PI, 0.0, 0.0))
	var flower_mat := _mat(0xffffff, 0.5)
	var center_mat := _mat(0xfacc15, 0.4)
	for fp in [[-0.06, 0.20, 0.05], [0.08, 0.19, -0.02]]:
		_cyl(hg, 0.032, 0.032, 0.012, 6, flower_mat, Vector3(fp[0], fp[1], fp[2]))
		_sphere(hg, 0.014, 5, center_mat, Vector3(fp[0], fp[1] + 0.008, fp[2]))

static func _build_potato_plant(root: DioramaProp) -> void:
	root.is_interactable = true
	root.harvest_yield = "potato"
	_add_collider(root, Vector3(0.58, 0.45, 0.58), 0.22)
	_sphere(root, 0.22, 8, _mat(0x5c3a1d, 0.95), Vector3(0.0, 0.06, 0.0), Vector3(1.2, 0.45, 1.2))
	var leaf_mat := _mat(0x15803d, 0.8)
	var stem_mat := _mat(0x166534, 0.85)
	for i in range(5):
		var a := (float(i) / 5.0) * TAU
		_cyl(root, 0.014, 0.018, 0.22, 5, stem_mat, Vector3(cos(a) * 0.06, 0.16, sin(a) * 0.06), Vector3(sin(a) * 0.25, 0.0, -cos(a) * 0.25))
		_sphere(root, 0.085, 6, leaf_mat, Vector3(cos(a) * 0.11, 0.24, sin(a) * 0.11), Vector3(1.1, 0.6, 1.1))
	# Harvestable golden potatoes peeking out of soil mound
	var hg := Node3D.new()
	root.add_child(hg)
	root.refs["harvest_group"] = hg
	var pot_mat := _mat(0xd97706, 0.8)
	var tubers := [[-0.16, 0.07, 0.12], [0.17, 0.065, 0.09], [-0.08, 0.075, -0.16], [0.13, 0.07, -0.13]]
	for tb in tubers:
		_sphere(hg, 0.052, 7, pot_mat, Vector3(tb[0], tb[1], tb[2]), Vector3(1.3, 0.85, 0.95))

# =============================================================================
# 4. CREATURES (12)
# =============================================================================

static func _build_human(root: DioramaProp) -> void:
	root.is_interactable = true
	_add_collider(root, Vector3(0.45, 0.85, 0.45), 0.42)
	var sub := Node3D.new()
	root.add_child(sub)
	root.refs["sub_group"] = sub
	
	var skin_mat := _mat(0xfdba74, 0.6)
	var shirt_mat := _mat(root.shirt_color, 0.7, 0.0, 1.0, -1, 0.0, true)
	root.refs["shirt_mat"] = shirt_mat
	var pants_mat := _mat(0x1e3a8a, 0.8)
	var hair_mat := _mat(0x451a03, 0.85)
	var shoe_mat := _mat(0x1f2937, 0.8)
	var eye_mat := _mat(0x0f172a, 0.2)
	
	# Legs
	var leg_l := Node3D.new()
	leg_l.position = Vector3(-0.065, 0.22, 0.0)
	sub.add_child(leg_l)
	_box(leg_l, Vector3(0.09, 0.22, 0.09), pants_mat, Vector3(0.0, -0.10, 0.0))
	_box(leg_l, Vector3(0.095, 0.05, 0.12), shoe_mat, Vector3(0.0, -0.20, 0.015))
	root.refs["leg_l"] = leg_l
	
	var leg_r := Node3D.new()
	leg_r.position = Vector3(0.065, 0.22, 0.0)
	sub.add_child(leg_r)
	_box(leg_r, Vector3(0.09, 0.22, 0.09), pants_mat, Vector3(0.0, -0.10, 0.0))
	_box(leg_r, Vector3(0.095, 0.05, 0.12), shoe_mat, Vector3(0.0, -0.20, 0.015))
	root.refs["leg_r"] = leg_r
	
	# Torso
	_box(sub, Vector3(0.24, 0.28, 0.14), shirt_mat, Vector3(0.0, 0.36, 0.0))
	
	# Arms
	var arm_l := Node3D.new()
	arm_l.position = Vector3(-0.16, 0.47, 0.0)
	sub.add_child(arm_l)
	_box(arm_l, Vector3(0.075, 0.22, 0.075), shirt_mat, Vector3(0.0, -0.09, 0.0))
	_sphere(arm_l, 0.04, 5, skin_mat, Vector3(0.0, -0.21, 0.0))
	root.refs["arm_l"] = arm_l
	
	var arm_r := Node3D.new()
	arm_r.position = Vector3(0.16, 0.47, 0.0)
	sub.add_child(arm_r)
	_box(arm_r, Vector3(0.075, 0.22, 0.075), shirt_mat, Vector3(0.0, -0.09, 0.0))
	_sphere(arm_r, 0.04, 5, skin_mat, Vector3(0.0, -0.21, 0.0))
	root.refs["arm_r"] = arm_r
	
	# Head & Hair & Eyes
	_sphere(sub, 0.115, 8, skin_mat, Vector3(0.0, 0.62, 0.0))
	_sphere(sub, 0.122, 8, hair_mat, Vector3(0.0, 0.65, -0.02), Vector3(1.02, 0.85, 1.05))
	_sphere(sub, 0.016, 5, eye_mat, Vector3(-0.04, 0.63, 0.105))
	_sphere(sub, 0.016, 5, eye_mat, Vector3(0.04, 0.63, 0.105))

static func _build_cat(root: DioramaProp) -> void:
	root.is_interactable = true
	_add_collider(root, Vector3(0.42, 0.42, 0.48), 0.20)
	var sub := Node3D.new()
	root.add_child(sub)
	root.refs["sub_group"] = sub
	var fur_mat := _mat(0xf97316, 0.75)
	var white_mat := _mat(0xfff7ed, 0.8)
	var ear_pink := _mat(0xfda4af, 0.6)
	var eye_mat := _mat(0x10b981, 0.2)
	
	var body := _box(sub, Vector3(0.18, 0.16, 0.30), fur_mat, Vector3(0.0, 0.15, 0.0))
	root.refs["body"] = body
	_box(sub, Vector3(0.14, 0.11, 0.08), white_mat, Vector3(0.0, 0.13, 0.13))
	
	var head := Node3D.new()
	head.position = Vector3(0.0, 0.25, 0.16)
	sub.add_child(head)
	root.refs["head"] = head
	_box(head, Vector3(0.17, 0.15, 0.15), fur_mat)
	for sx in [-1.0, 1.0]:
		_cone(head, 0.038, 0.07, 4, fur_mat, Vector3(sx * 0.055, 0.10, 0.0), Vector3(0.0, PI * 0.25, 0.0))
		_sphere(head, 0.018, 5, eye_mat, Vector3(sx * 0.042, 0.015, 0.078))
	_sphere(head, 0.016, 5, ear_pink, Vector3(0.0, -0.01, 0.082))
	
	for lx in [-0.06, 0.06]:
		for lz in [-0.10, 0.10]:
			_cyl(sub, 0.025, 0.022, 0.10, 5, white_mat, Vector3(lx, 0.05, lz))
	
	var tail := Node3D.new()
	tail.position = Vector3(0.0, 0.18, -0.15)
	sub.add_child(tail)
	root.refs["tail"] = tail
	_cyl(tail, 0.022, 0.025, 0.22, 5, fur_mat, Vector3(0.0, 0.09, -0.04), Vector3(-0.45, 0.0, 0.0))

static func _build_dog(root: DioramaProp) -> void:
	root.is_interactable = true
	_add_collider(root, Vector3(0.45, 0.48, 0.52), 0.24)
	var sub := Node3D.new()
	root.add_child(sub)
	root.refs["sub_group"] = sub
	var coat_mat := _mat(0xd97706, 0.75)
	var ear_mat := _mat(0x78350f, 0.85)
	var collar_mat := _mat(0xef4444, 0.5)
	var nose_mat := _mat(0x1e293b, 0.3)
	
	_box(sub, Vector3(0.20, 0.18, 0.34), coat_mat, Vector3(0.0, 0.18, 0.0))
	_box(sub, Vector3(0.21, 0.05, 0.05), collar_mat, Vector3(0.0, 0.21, 0.15))
	var head := Node3D.new()
	head.position = Vector3(0.0, 0.29, 0.18)
	sub.add_child(head)
	_box(head, Vector3(0.18, 0.16, 0.17), coat_mat)
	_box(head, Vector3(0.10, 0.08, 0.10), coat_mat, Vector3(0.0, -0.02, 0.11))
	_sphere(head, 0.022, 5, nose_mat, Vector3(0.0, 0.0, 0.165))
	for sx in [-1.0, 1.0]:
		_box(head, Vector3(0.04, 0.11, 0.07), ear_mat, Vector3(sx * 0.10, -0.01, 0.0))
		_sphere(head, 0.018, 5, nose_mat, Vector3(sx * 0.048, 0.025, 0.088))
	for lx in [-0.07, 0.07]:
		for lz in [-0.12, 0.12]:
			_cyl(sub, 0.028, 0.025, 0.12, 5, coat_mat, Vector3(lx, 0.06, lz))
	var tail := Node3D.new()
	tail.position = Vector3(0.0, 0.22, -0.17)
	sub.add_child(tail)
	root.refs["tail"] = tail
	_cyl(tail, 0.02, 0.028, 0.16, 5, ear_mat, Vector3(0.0, 0.06, -0.03), Vector3(-0.5, 0.0, 0.0))

static func _build_duck(root: DioramaProp) -> void:
	root.is_interactable = true
	_add_collider(root, Vector3(0.38, 0.38, 0.42), 0.18)
	var sub := Node3D.new()
	root.add_child(sub)
	root.refs["sub_group"] = sub
	var body_mat := _mat(0xfacc15, 0.6)
	var beak_mat := _mat(0xf97316, 0.5)
	var eye_mat := _mat(0x0f172a, 0.2)
	
	_sphere(sub, 0.13, 8, body_mat, Vector3(0.0, 0.14, 0.0), Vector3(0.95, 0.85, 1.25))
	_sphere(sub, 0.09, 7, body_mat, Vector3(0.0, 0.25, 0.11))
	_box(sub, Vector3(0.07, 0.03, 0.08), beak_mat, Vector3(0.0, 0.24, 0.21))
	for sx in [-1.0, 1.0]:
		_sphere(sub, 0.014, 5, eye_mat, Vector3(sx * 0.055, 0.265, 0.16))
	var legs: Array = []
	for lx in [-0.045, 0.045]:
		var leg := _cyl(sub, 0.012, 0.012, 0.07, 5, beak_mat, Vector3(lx, 0.035, 0.0))
		legs.append(leg)
	root.refs["legs"] = legs

static func _build_squirrel(root: DioramaProp) -> void:
	root.is_interactable = true
	_add_collider(root, Vector3(0.38, 0.42, 0.45), 0.20)
	var sub := Node3D.new()
	root.add_child(sub)
	root.refs["sub_group"] = sub
	
	var fur_mat := _mat(0xc2410c, 0.75)
	var belly_mat := _mat(0xfed7aa, 0.85)
	var tail_mat := _mat(0x9a3412, 0.8)
	var eye_mat := _mat(0x1e293b, 0.15)
	var nut_mat := _mat(0x78350f, 0.6)
	var nut_cap := _mat(0x451a03, 0.9)
	
	_box(sub, Vector3(0.16, 0.20, 0.15), fur_mat, Vector3(0.0, 0.13, 0.02))
	_box(sub, Vector3(0.11, 0.15, 0.03), belly_mat, Vector3(0.0, 0.13, 0.09))
	for sx in [-0.06, 0.06]:
		_box(sub, Vector3(0.05, 0.04, 0.09), fur_mat, Vector3(sx, 0.02, 0.04))
	# Head + ears + eyes + nose + acorn in paws
	var head := Node3D.new()
	head.position = Vector3(0.0, 0.26, 0.06)
	sub.add_child(head)
	root.refs["head"] = head
	_box(head, Vector3(0.14, 0.13, 0.15), fur_mat)
	for ex in [-0.048, 0.048]:
		_cone(head, 0.025, 0.06, 4, fur_mat, Vector3(ex, 0.08, -0.01))
		_sphere(head, 0.015, 5, eye_mat, Vector3(ex * 1.15, 0.015, 0.072))
	_box(head, Vector3(0.025, 0.02, 0.02), eye_mat, Vector3(0.0, -0.01, 0.082))
	# Acorn held in front paws
	_box(sub, Vector3(0.035, 0.035, 0.07), fur_mat, Vector3(-0.045, 0.16, 0.11))
	_box(sub, Vector3(0.035, 0.035, 0.07), fur_mat, Vector3(0.045, 0.16, 0.11))
	_sphere(sub, 0.032, 6, nut_mat, Vector3(0.0, 0.15, 0.15))
	_cyl(sub, 0.035, 0.028, 0.02, 6, nut_cap, Vector3(0.0, 0.175, 0.15))
	# Bushy S-curved tail
	var tail_group := Node3D.new()
	tail_group.position = Vector3(0.0, 0.08, -0.06)
	sub.add_child(tail_group)
	root.refs["tail_group"] = tail_group
	_box(tail_group, Vector3(0.13, 0.16, 0.12), tail_mat, Vector3(0.0, 0.06, -0.06), Vector3(-0.35, 0.0, 0.0))
	_box(tail_group, Vector3(0.15, 0.18, 0.14), fur_mat, Vector3(0.0, 0.19, -0.11), Vector3(0.15, 0.0, 0.0))
	_sphere(tail_group, 0.085, 6, tail_mat, Vector3(0.0, 0.29, -0.07))

static func _build_axolotl(root: DioramaProp) -> void:
	root.is_interactable = true
	_add_collider(root, Vector3(0.42, 0.30, 0.55), 0.12)
	var sub := Node3D.new()
	root.add_child(sub)
	root.refs["sub_group"] = sub
	
	var pink_mat := _mat(0xfbcfe8, 0.4)
	var gill_mat := _mat(0xf43f5e, 0.3)
	var dark_pink := _mat(0xf472b6, 0.5)
	var eye_mat := _mat(0x1e293b, 0.1)
	var fin_mat := _mat(0xfce7f3, 0.3, 0.0, 0.85)
	
	_box(sub, Vector3(0.18, 0.11, 0.38), pink_mat, Vector3(0.0, 0.08, 0.0))
	_box(sub, Vector3(0.24, 0.10, 0.18), pink_mat, Vector3(0.0, 0.08, 0.24))
	for ex in [-0.09, 0.09]:
		_sphere(sub, 0.02, 6, eye_mat, Vector3(ex, 0.12, 0.28))
	_box(sub, Vector3(0.09, 0.015, 0.01), dark_pink, Vector3(0.0, 0.05, 0.33))
	# 6 Feathery external gills (3 on each side)
	for side in [-1.0, 1.0]:
		var gzs := [0.18, 0.23, 0.28]
		for idx in range(3):
			var gz: float = gzs[idx]
			var angle := float(idx - 1) * 0.35 + (0.3 if side > 0.0 else -0.3)
			_cyl(sub, 0.012, 0.018, 0.14, 5, gill_mat, Vector3(side * 0.16, 0.12 + float(idx) * 0.02, gz), Vector3(-angle * 0.3, 0.0, side * (PI / 3.0 + angle * 0.4)))
			for f in range(3):
				_sphere(sub, 0.016, 4, gill_mat, Vector3(side * (0.19 + float(f) * 0.025), 0.14 + float(idx) * 0.025 + float(f) * 0.015, gz))
	# Undulating swimming tail & dorsal fin
	var tail_group := Node3D.new()
	tail_group.position = Vector3(0.0, 0.08, -0.19)
	sub.add_child(tail_group)
	root.refs["tail_group"] = tail_group
	_cone(tail_group, 0.08, 0.28, 6, pink_mat, Vector3(0.0, 0.0, -0.14), Vector3(-PI * 0.5, 0.0, 0.0))
	_box(tail_group, Vector3(0.02, 0.14, 0.36), fin_mat, Vector3(0.0, 0.02, -0.12))
	# 4 tiny sprawled feet
	for fx in [-0.12, 0.12]:
		for fz in [0.10, -0.10]:
			_box(sub, Vector3(0.06, 0.025, 0.07), pink_mat, Vector3(fx, 0.025, fz), Vector3(0.0, 0.3 if fx > 0.0 else -0.3, 0.0))

static func _build_pig(root: DioramaProp) -> void:
	root.is_interactable = true
	_add_collider(root, Vector3(0.45, 0.45, 0.55), 0.22)
	var sub := Node3D.new()
	root.add_child(sub)
	root.refs["sub_group"] = sub
	var pink_mat := _mat(0xf9a8d4, 0.65)
	var snout_mat := _mat(0xf472b6, 0.55)
	var hoof_mat := _mat(0x831843, 0.8)
	var eye_mat := _mat(0x1e293b, 0.2)
	
	_box(sub, Vector3(0.26, 0.22, 0.36), pink_mat, Vector3(0.0, 0.18, 0.0))
	var head := Node3D.new()
	head.position = Vector3(0.0, 0.24, 0.21)
	sub.add_child(head)
	root.refs["head"] = head
	_box(head, Vector3(0.20, 0.18, 0.18), pink_mat)
	_box(head, Vector3(0.11, 0.08, 0.06), snout_mat, Vector3(0.0, -0.02, 0.11))
	for sx in [-1.0, 1.0]:
		_box(head, Vector3(0.06, 0.08, 0.04), snout_mat, Vector3(sx * 0.08, 0.08, 0.02), Vector3(0.25, 0.0, sx * -0.25))
		_sphere(head, 0.018, 5, eye_mat, Vector3(sx * 0.055, 0.03, 0.092))
	for lx in [-0.08, 0.08]:
		for lz in [-0.12, 0.12]:
			_cyl(sub, 0.032, 0.028, 0.10, 6, pink_mat, Vector3(lx, 0.05, lz))
			_cyl(sub, 0.028, 0.028, 0.025, 6, hoof_mat, Vector3(lx, 0.012, lz))
	var tail := Node3D.new()
	tail.position = Vector3(0.0, 0.22, -0.19)
	sub.add_child(tail)
	root.refs["tail"] = tail
	_torus(tail, 0.032, 0.012, snout_mat, Vector3(0.0, 0.0, -0.02), Vector3(PI * 0.5, 0.0, 0.0))

static func _build_parrot(root: DioramaProp) -> void:
	root.is_interactable = true
	_add_collider(root, Vector3(0.38, 0.48, 0.38), 0.24)
	var sub := Node3D.new()
	root.add_child(sub)
	root.refs["sub_group"] = sub
	var red_mat := _mat(0xef4444, 0.55)
	var yellow_mat := _mat(0xfacc15, 0.55)
	var blue_mat := _mat(0x2563eb, 0.55)
	var beak_mat := _mat(0xfef08a, 0.4)
	var eye_mat := _mat(0x0f172a, 0.15)
	
	_cyl(sub, 0.075, 0.065, 0.22, 7, red_mat, Vector3(0.0, 0.16, 0.0), Vector3(0.18, 0.0, 0.0))
	var head := Node3D.new()
	head.position = Vector3(0.0, 0.29, 0.04)
	sub.add_child(head)
	root.refs["head"] = head
	_sphere(head, 0.072, 7, red_mat)
	_cone(head, 0.032, 0.07, 5, beak_mat, Vector3(0.0, -0.01, 0.085), Vector3(PI * 0.55, 0.0, 0.0))
	for sx in [-1.0, 1.0]:
		_sphere(head, 0.025, 5, _mat(0xffffff, 0.5), Vector3(sx * 0.055, 0.01, 0.035))
		_sphere(head, 0.014, 5, eye_mat, Vector3(sx * 0.066, 0.01, 0.042))
	# Colourful wings (yellow + blue)
	var wing_l := Node3D.new()
	wing_l.position = Vector3(-0.075, 0.22, 0.0)
	sub.add_child(wing_l)
	_box(wing_l, Vector3(0.03, 0.16, 0.10), yellow_mat, Vector3(-0.01, -0.05, -0.01))
	_box(wing_l, Vector3(0.028, 0.12, 0.08), blue_mat, Vector3(-0.012, -0.10, -0.03))
	root.refs["wing_l"] = wing_l
	
	var wing_r := Node3D.new()
	wing_r.position = Vector3(0.075, 0.22, 0.0)
	sub.add_child(wing_r)
	_box(wing_r, Vector3(0.03, 0.16, 0.10), yellow_mat, Vector3(0.01, -0.05, -0.01))
	_box(wing_r, Vector3(0.028, 0.12, 0.08), blue_mat, Vector3(0.012, -0.10, -0.03))
	root.refs["wing_r"] = wing_r
	# Long tail feathers
	_box(sub, Vector3(0.06, 0.20, 0.025), blue_mat, Vector3(0.0, 0.08, -0.10), Vector3(0.55, 0.0, 0.0))

static func _build_horse(root: DioramaProp) -> void:
	root.is_interactable = true
	_add_collider(root, Vector3(0.55, 0.90, 0.80), 0.45)
	var sub := Node3D.new()
	root.add_child(sub)
	root.refs["sub_group"] = sub
	var coat_mat := _mat(0x92400e, 0.7)
	var mane_mat := _mat(0x271206, 0.85)
	var blaze_mat := _mat(0xffffff, 0.6)
	var eye_mat := _mat(0x0f172a, 0.15)
	
	_box(sub, Vector3(0.28, 0.26, 0.56), coat_mat, Vector3(0.0, 0.42, 0.0))
	for lx in [-0.095, 0.095]:
		for lz in [-0.21, 0.21]:
			_cyl(sub, 0.038, 0.032, 0.30, 6, coat_mat, Vector3(lx, 0.15, lz))
			_cyl(sub, 0.034, 0.036, 0.04, 6, mane_mat, Vector3(lx, 0.02, lz))
	var neck_group := Node3D.new()
	neck_group.position = Vector3(0.0, 0.50, 0.22)
	neck_group.rotation.x = 0.25
	sub.add_child(neck_group)
	root.refs["neck_group"] = neck_group
	_box(neck_group, Vector3(0.16, 0.28, 0.16), coat_mat, Vector3(0.0, 0.12, 0.04))
	_box(neck_group, Vector3(0.05, 0.28, 0.06), mane_mat, Vector3(0.0, 0.13, -0.05))
	_box(neck_group, Vector3(0.16, 0.15, 0.26), coat_mat, Vector3(0.0, 0.26, 0.12))
	_box(neck_group, Vector3(0.05, 0.02, 0.16), blaze_mat, Vector3(0.0, 0.338, 0.14))
	for sx in [-1.0, 1.0]:
		_cone(neck_group, 0.028, 0.07, 4, coat_mat, Vector3(sx * 0.05, 0.36, 0.04))
		_sphere(neck_group, 0.02, 5, eye_mat, Vector3(sx * 0.082, 0.28, 0.14))
	var tail := Node3D.new()
	tail.position = Vector3(0.0, 0.48, -0.28)
	sub.add_child(tail)
	root.refs["tail"] = tail
	_box(tail, Vector3(0.07, 0.28, 0.07), mane_mat, Vector3(0.0, -0.12, -0.04), Vector3(0.25, 0.0, 0.0))

static func _build_elephant(root: DioramaProp) -> void:
	root.is_interactable = true
	_add_collider(root, Vector3(0.70, 0.85, 0.85), 0.42)
	var sub := Node3D.new()
	root.add_child(sub)
	root.refs["sub_group"] = sub
	var grey_mat := _mat(0x94a3b8, 0.85)
	var inner_ear := _mat(0xfda4af, 0.8)
	var tusk_mat := _mat(0xfefce8, 0.4)
	var eye_mat := _mat(0x0f172a, 0.2)
	
	_box(sub, Vector3(0.44, 0.38, 0.56), grey_mat, Vector3(0.0, 0.40, -0.02))
	for lx in [-0.14, 0.14]:
		for lz in [-0.20, 0.16]:
			_cyl(sub, 0.075, 0.07, 0.24, 8, grey_mat, Vector3(lx, 0.12, lz))
	var head := Node3D.new()
	head.position = Vector3(0.0, 0.48, 0.30)
	sub.add_child(head)
	_box(head, Vector3(0.32, 0.30, 0.28), grey_mat)
	for sx in [-1.0, 1.0]:
		_sphere(head, 0.022, 5, eye_mat, Vector3(sx * 0.14, 0.04, 0.12))
		_cone(head, 0.025, 0.16, 6, tusk_mat, Vector3(sx * 0.09, -0.10, 0.18), Vector3(PI * 0.4, 0.0, 0.0))
	# Large flapping ears
	var ear_l := Node3D.new()
	ear_l.position = Vector3(-0.16, 0.02, 0.0)
	head.add_child(ear_l)
	_box(ear_l, Vector3(0.22, 0.28, 0.04), grey_mat, Vector3(-0.10, 0.0, 0.0))
	_box(ear_l, Vector3(0.16, 0.20, 0.045), inner_ear, Vector3(-0.10, -0.01, 0.005))
	root.refs["ear_l"] = ear_l
	
	var ear_r := Node3D.new()
	ear_r.position = Vector3(0.16, 0.02, 0.0)
	head.add_child(ear_r)
	_box(ear_r, Vector3(0.22, 0.28, 0.04), grey_mat, Vector3(0.10, 0.0, 0.0))
	_box(ear_r, Vector3(0.16, 0.20, 0.045), inner_ear, Vector3(0.10, -0.01, 0.005))
	root.refs["ear_r"] = ear_r
	# Articulated trunk
	var trunk_group := Node3D.new()
	trunk_group.position = Vector3(0.0, -0.02, 0.15)
	head.add_child(trunk_group)
	root.refs["trunk_group"] = trunk_group
	_cyl(trunk_group, 0.055, 0.042, 0.26, 7, grey_mat, Vector3(0.0, -0.11, 0.03), Vector3(0.25, 0.0, 0.0))
	_cyl(trunk_group, 0.040, 0.032, 0.14, 7, grey_mat, Vector3(0.0, -0.24, 0.10), Vector3(0.85, 0.0, 0.0))

static func _build_lion(root: DioramaProp) -> void:
	root.is_interactable = true
	_add_collider(root, Vector3(0.50, 0.65, 0.72), 0.32)
	var sub := Node3D.new()
	root.add_child(sub)
	root.refs["sub_group"] = sub
	var fur_mat := _mat(0xf59e0b, 0.7)
	var mane_mat := _mat(0x92400e, 0.85)
	var muzzle_mat := _mat(0xfef3c7, 0.7)
	var eye_mat := _mat(0x1e293b, 0.2)
	
	_box(sub, Vector3(0.26, 0.24, 0.46), fur_mat, Vector3(0.0, 0.28, -0.02))
	for lx in [-0.09, 0.09]:
		for lz in [-0.18, 0.15]:
			_cyl(sub, 0.042, 0.038, 0.18, 6, fur_mat, Vector3(lx, 0.09, lz))
	var head := Node3D.new()
	head.position = Vector3(0.0, 0.36, 0.24)
	sub.add_child(head)
	root.refs["head"] = head
	# Thick mane block
	_box(head, Vector3(0.36, 0.36, 0.22), mane_mat, Vector3(0.0, 0.0, -0.02))
	_box(head, Vector3(0.22, 0.22, 0.18), fur_mat, Vector3(0.0, 0.0, 0.05))
	_box(head, Vector3(0.14, 0.10, 0.08), muzzle_mat, Vector3(0.0, -0.04, 0.15))
	_sphere(head, 0.022, 5, mane_mat, Vector3(0.0, -0.01, 0.19))
	for sx in [-1.0, 1.0]:
		_sphere(head, 0.02, 5, eye_mat, Vector3(sx * 0.06, 0.04, 0.145))
	var tail := Node3D.new()
	tail.position = Vector3(0.0, 0.32, -0.25)
	sub.add_child(tail)
	root.refs["tail"] = tail
	_cyl(tail, 0.018, 0.02, 0.26, 5, fur_mat, Vector3(0.0, 0.05, -0.10), Vector3(-0.85, 0.0, 0.0))
	_sphere(tail, 0.04, 6, mane_mat, Vector3(0.0, 0.12, -0.20))

static func _build_white_tiger(root: DioramaProp) -> void:
	root.is_interactable = true
	_add_collider(root, Vector3(0.50, 0.60, 0.72), 0.30)
	var sub := Node3D.new()
	root.add_child(sub)
	root.refs["sub_group"] = sub
	var white_mat := _mat(0xf8fafc, 0.7)
	var stripe_mat := _mat(0x1e293b, 0.85)
	var nose_mat := _mat(0xf472b6, 0.5)
	var eye_mat := _mat(0x38bdf8, 0.15)
	
	_box(sub, Vector3(0.26, 0.23, 0.48), white_mat, Vector3(0.0, 0.27, 0.0))
	for sz in [-0.14, -0.02, 0.10]:
		_box(sub, Vector3(0.27, 0.16, 0.035), stripe_mat, Vector3(0.0, 0.29, sz))
	for lx in [-0.09, 0.09]:
		for lz in [-0.17, 0.17]:
			_cyl(sub, 0.042, 0.038, 0.18, 6, white_mat, Vector3(lx, 0.09, lz))
	var head := Node3D.new()
	head.position = Vector3(0.0, 0.35, 0.27)
	sub.add_child(head)
	_box(head, Vector3(0.24, 0.21, 0.20), white_mat)
	_box(head, Vector3(0.14, 0.10, 0.08), white_mat, Vector3(0.0, -0.03, 0.12))
	_sphere(head, 0.022, 5, nose_mat, Vector3(0.0, -0.01, 0.165))
	for sx in [-1.0, 1.0]:
		_sphere(head, 0.04, 5, white_mat, Vector3(sx * 0.09, 0.11, -0.02))
		_sphere(head, 0.02, 5, eye_mat, Vector3(sx * 0.06, 0.03, 0.105))
		_box(head, Vector3(0.02, 0.08, 0.12), stripe_mat, Vector3(sx * 0.115, 0.01, 0.0))
	var tail := Node3D.new()
	tail.position = Vector3(0.0, 0.30, -0.24)
	sub.add_child(tail)
	root.refs["tail"] = tail
	_cyl(tail, 0.025, 0.028, 0.28, 6, white_mat, Vector3(0.0, 0.04, -0.11), Vector3(-0.95, 0.0, 0.0))

# =============================================================================
# 5. DECO ITEMS (5)
# =============================================================================

static func _build_streetlamp(root: DioramaProp) -> void:
	root.is_interactable = true
	_add_collider(root, Vector3(0.42, 1.65, 0.42), 0.82)
	var iron_mat := _mat(0x1e293b, 0.45, 0.6)
	_cyl(root, 0.09, 0.13, 0.16, 8, iron_mat, Vector3(0.0, 0.08, 0.0))
	_cyl(root, 0.035, 0.05, 1.25, 8, iron_mat, Vector3(0.0, 0.72, 0.0))
	_box(root, Vector3(0.04, 0.04, 0.24), iron_mat, Vector3(0.0, 1.34, 0.09))
	_cone(root, 0.14, 0.10, 6, iron_mat, Vector3(0.0, 1.40, 0.18))
	
	var glass_mat := _mat(0xfef08a, 0.2, 0.0, 0.65, 0xfef08a, 0.6, true)
	var bulb_mat := _mat(0xfef08a, 0.1, 0.0, 1.0, 0xfde047, 1.8, true)
	root.refs["glass_mat"] = glass_mat
	root.refs["bulb_mat"] = bulb_mat
	_cyl(root, 0.08, 0.06, 0.14, 6, glass_mat, Vector3(0.0, 1.29, 0.18))
	_sphere(root, 0.04, 6, bulb_mat, Vector3(0.0, 1.29, 0.18))
	
	var omni := OmniLight3D.new()
	omni.position = Vector3(0.0, 1.22, 0.18)
	omni.light_color = Color("#fde047")
	omni.light_energy = 1.35
	omni.omni_range = 4.2
	omni.visible = false
	root.add_child(omni)
	root.refs["omni_light"] = omni

static func _build_bench(root: DioramaProp) -> void:
	root.is_interactable = true
	_add_collider(root, Vector3(0.85, 0.55, 0.48), 0.26)
	var wood_mat := _mat(0xb45309, 0.75)
	var iron_mat := _mat(0x1e293b, 0.5, 0.5)
	# Seat planks
	_box(root, Vector3(0.76, 0.04, 0.11), wood_mat, Vector3(0.0, 0.22, -0.05))
	_box(root, Vector3(0.76, 0.04, 0.11), wood_mat, Vector3(0.0, 0.22, 0.08))
	# Backrest planks
	_box(root, Vector3(0.76, 0.09, 0.035), wood_mat, Vector3(0.0, 0.34, -0.12), Vector3(-0.12, 0.0, 0.0))
	_box(root, Vector3(0.76, 0.09, 0.035), wood_mat, Vector3(0.0, 0.45, -0.14), Vector3(-0.12, 0.0, 0.0))
	# Cast iron legs & armrests
	for lx in [-0.32, 0.32]:
		_box(root, Vector3(0.045, 0.22, 0.28), iron_mat, Vector3(lx, 0.11, 0.0))
		_box(root, Vector3(0.045, 0.30, 0.045), iron_mat, Vector3(lx, 0.35, -0.13), Vector3(-0.12, 0.0, 0.0))
		_box(root, Vector3(0.045, 0.035, 0.26), iron_mat, Vector3(lx, 0.31, 0.01))

static func _build_fountain(root: DioramaProp) -> void:
	root.is_interactable = true
	_add_collider(root, Vector3(1.65, 1.25, 1.65), 0.62)
	var stone_mat := _mat(0xcbd5e1, 0.75)
	var rim_mat := _mat(0x94a3b8, 0.8)
	var water_mat := _mat(0x38bdf8, 0.12, 0.1, 0.88)
	var spray_mat := _mat(0xe0f2fe, 0.15, 0.0, 0.85)
	# Round basin + torus rim + lower water
	_cyl(root, 0.78, 0.72, 0.26, 12, stone_mat, Vector3(0.0, 0.13, 0.0))
	_torus(root, 0.75, 0.06, rim_mat, Vector3(0.0, 0.26, 0.0))
	_cyl(root, 0.71, 0.71, 0.20, 12, water_mat, Vector3(0.0, 0.15, 0.0))
	# Center pedestal + upper bowl + upper water + animated dome
	_cyl(root, 0.13, 0.18, 0.68, 10, stone_mat, Vector3(0.0, 0.44, 0.0))
	_cyl(root, 0.38, 0.16, 0.14, 10, rim_mat, Vector3(0.0, 0.74, 0.0))
	_cyl(root, 0.34, 0.34, 0.04, 10, water_mat, Vector3(0.0, 0.80, 0.0))
	_cyl(root, 0.06, 0.09, 0.24, 8, stone_mat, Vector3(0.0, 0.90, 0.0))
	var dome := _sphere(root, 0.12, 8, spray_mat, Vector3(0.0, 1.06, 0.0), Vector3(1.1, 1.3, 1.1))
	root.refs["water_dome"] = dome

static func _build_fence(root: DioramaProp) -> void:
	root.is_interactable = true
	_add_collider(root, Vector3(0.85, 0.55, 0.35), 0.28)
	var post_mat := _mat(0x92400e, 0.85)
	var rail_mat := _mat(0xb45309, 0.8)
	# Central post + pyramid cap
	_box(root, Vector3(0.11, 0.48, 0.11), post_mat, Vector3(0.0, 0.24, 0.0))
	_cone(root, 0.085, 0.08, 4, post_mat, Vector3(0.0, 0.52, 0.0), Vector3(0.0, PI * 0.25, 0.0))
	
	# Default horizontal rails when isolated (no neighbors)
	var def_arms := Node3D.new()
	root.add_child(def_arms)
	root.refs["default_arms"] = def_arms
	for sx in [-0.38, 0.38]:
		_box(def_arms, Vector3(0.09, 0.44, 0.09), post_mat, Vector3(sx, 0.22, 0.0))
	_box(def_arms, Vector3(0.84, 0.06, 0.04), rail_mat, Vector3(0.0, 0.36, 0.0))
	_box(def_arms, Vector3(0.84, 0.06, 0.04), rail_mat, Vector3(0.0, 0.18, 0.0))
	
	# Directional connection arms (N = -Z, S = +Z, E = +X, W = -X)
	var arm_defs := {
		"n": [Vector3(0.0, 0.0, -0.25), Vector3(0.04, 0.06, 0.50)],
		"s": [Vector3(0.0, 0.0, 0.25), Vector3(0.04, 0.06, 0.50)],
		"e": [Vector3(0.25, 0.0, 0.0), Vector3(0.50, 0.06, 0.04)],
		"w": [Vector3(-0.25, 0.0, 0.0), Vector3(0.50, 0.06, 0.04)],
	}
	for k in arm_defs:
		var arm := Node3D.new()
		arm.visible = false
		root.add_child(arm)
		var p: Vector3 = arm_defs[k][0]
		var s: Vector3 = arm_defs[k][1]
		_box(arm, s, rail_mat, Vector3(p.x, 0.36, p.z))
		_box(arm, s, rail_mat, Vector3(p.x, 0.18, p.z))
		root.refs["arm_" + k] = arm

static func _build_beer_table(root: DioramaProp) -> void:
	root.is_interactable = true
	_add_collider(root, Vector3(0.88, 0.50, 0.82), 0.25)
	var wood_mat := _mat(0xd97706, 0.7)
	var leg_mat := _mat(0x166534, 0.6, 0.4)
	# Table top & legs
	_box(root, Vector3(0.82, 0.045, 0.34), wood_mat, Vector3(0.0, 0.34, 0.0))
	for tx in [-0.32, 0.32]:
		_box(root, Vector3(0.035, 0.33, 0.28), leg_mat, Vector3(tx, 0.165, 0.0))
	# Two side benches
	for bz in [-0.28, 0.28]:
		_box(root, Vector3(0.82, 0.035, 0.14), wood_mat, Vector3(0.0, 0.20, bz))
		for bx in [-0.32, 0.32]:
			_box(root, Vector3(0.03, 0.19, 0.12), leg_mat, Vector3(bx, 0.095, bz))
	# 4 Foamy beer mugs on the table!
	var glass_mat := _mat(0xfbbf24, 0.2, 0.1)
	var foam_mat := _mat(0xffffff, 0.6)
	for mp in [[-0.22, -0.06], [0.06, 0.07], [0.24, -0.04], [-0.08, 0.05]]:
		_cyl(root, 0.028, 0.028, 0.075, 6, glass_mat, Vector3(mp[0], 0.40, mp[1]))
		_sphere(root, 0.030, 5, foam_mat, Vector3(mp[0], 0.445, mp[1]))
