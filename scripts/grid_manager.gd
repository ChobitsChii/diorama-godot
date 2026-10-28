class_name GridManager
extends Node3D

## Manages the 2D grid state (ground tiles on Layer 0, objects/creatures on Layer 1),
## multi-tile footprints (1x1 and 2x2), sitting/perching/swimming rules,
## and automatic neighbor connections (fence, townhouse, apartment).

signal grid_changed()
signal object_placed(entry: Dictionary)
signal object_removed(entry: Dictionary)

@export var grid_size: int = 12:
	set(value):
		grid_size = clampi(value, 4, 32)

# Key: "gx,gz" -> Dictionary { id, type, gx, gz, rotation, size, node }
var ground_tiles: Dictionary = {}

# Key: id (String) -> Dictionary { id, type, gx, gz, rotation, size, node }
var objects: Dictionary = {}

# Key: "gx,gz" -> Array of object IDs occupying that cell
var _cell_occupancy: Dictionary = {}

var _next_id: int = 1
var _ground_container: Node3D
var _object_container: Node3D
var _is_night: bool = false

const SITTERS: Array[String] = ["human", "cat", "dog", "pig"]
const SEATS: Array[String] = ["bench", "beertable"]
const PERCHERS: Array[String] = ["parrot", "squirrel"]
const PERCHES: Array[String] = ["tree", "pine", "streetlamp"]
const AQUATIC: Array[String] = ["duck", "axolotl"]
const AUTOTILE_TYPES: Array[String] = ["fence", "townhouse", "apartment"]

func _ready() -> void:
	_ensure_containers()

func _ensure_containers() -> void:
	if not _ground_container:
		_ground_container = Node3D.new()
		_ground_container.name = "GroundContainer"
		add_child(_ground_container)
	if not _object_container:
		_object_container = Node3D.new()
		_object_container.name = "ObjectContainer"
		add_child(_object_container)

func grid_to_world(gx: int, gz: int, footprint: Vector2i = Vector2i(1, 1)) -> Vector3:
	var half := float(grid_size) * 0.5
	var wx := (float(gx) - half) + float(footprint.x) * 0.5
	var wz := (float(gz) - half) + float(footprint.y) * 0.5
	return Vector3(wx, 0.0, wz)

func world_to_grid(world_pos: Vector3) -> Vector2i:
	var half := float(grid_size) * 0.5
	var gx := int(floor(world_pos.x + half))
	var gz := int(floor(world_pos.z + half))
	return Vector2i(gx, gz)

func is_within_bounds(gx: int, gz: int, footprint: Vector2i = Vector2i(1, 1)) -> bool:
	return gx >= 0 and gz >= 0 and (gx + footprint.x) <= grid_size and (gz + footprint.y) <= grid_size

func get_ground_at(gx: int, gz: int) -> Dictionary:
	var key := "%d,%d" % [gx, gz]
	return ground_tiles.get(key, {})

func get_objects_at(gx: int, gz: int) -> Array[Dictionary]:
	var key := "%d,%d" % [gx, gz]
	var result: Array[Dictionary] = []
	if _cell_occupancy.has(key):
		for obj_id in _cell_occupancy[key]:
			if objects.has(obj_id):
				result.append(objects[obj_id])
	return result

func get_primary_object_at(gx: int, gz: int) -> Dictionary:
	var objs := get_objects_at(gx, gz)
	if objs.is_empty():
		return {}
	for o in objs:
		if o["type"] in SITTERS or o["type"] in PERCHERS or o["type"] in AQUATIC:
			return o
	return objs.back()

func can_place(type_id: String, gx: int, gz: int, ignore_id: String = "") -> bool:
	var norm := Catalog.normalize_type(type_id)
	var item_def := Catalog.get_item(norm)
	if item_def.is_empty():
		return false
	
	var footprint: Vector2i = item_def.get("size", Vector2i(1, 1))
	if not is_within_bounds(gx, gz, footprint):
		return false
	
	if item_def.get("is_ground", false):
		return true
	
	var is_sitter := norm in SITTERS
	var is_seat := norm in SEATS
	var is_percher := norm in PERCHERS
	var is_perch := norm in PERCHES
	var is_aquatic := norm in AQUATIC
	
	for dx in range(footprint.x):
		for dz in range(footprint.y):
			var cx := gx + dx
			var cz := gz + dz
			var cell_objs := get_objects_at(cx, cz)
			var filtered: Array[Dictionary] = []
			for co in cell_objs:
				if co["id"] != ignore_id:
					filtered.append(co)
			
			if filtered.is_empty():
				continue
			
			# Sitting rule: Bench holds up to 2 sitters, BeerTable holds up to 4 sitters
			if is_sitter:
				var seat_obj := {}
				var sitters_count := 0
				for co in filtered:
					if co["type"] in SEATS:
						seat_obj = co
					elif co["type"] in SITTERS:
						sitters_count += 1
					else:
						return false
				if seat_obj.is_empty():
					return false
				var max_s := 4 if seat_obj["type"] == "beertable" else 2
				if sitters_count >= max_s:
					return false
				continue
			
			if is_seat:
				var max_s := 4 if norm == "beertable" else 2
				var sitters_count := 0
				for co in filtered:
					if co["type"] in SITTERS:
						sitters_count += 1
					else:
						return false
				if sitters_count > max_s:
					return false
				continue
			
			# Perching rule: Tree, Pine, Streetlamp hold up to 2 perchers (Parrot, Squirrel)
			if is_percher:
				var has_perch := false
				var perchers_count := 0
				for co in filtered:
					if co["type"] in PERCHES:
						has_perch = true
					elif co["type"] in PERCHERS:
						perchers_count += 1
					else:
						return false
				if not has_perch or perchers_count >= 2:
					return false
				continue
			
			if is_perch:
				var perchers_count := 0
				for co in filtered:
					if co["type"] in PERCHERS:
						perchers_count += 1
					else:
						return false
				if perchers_count > 2:
					return false
				continue
			
			# Aquatic rule: Pond holds up to 2 aquatic creatures (Duck, Axolotl)
			if is_aquatic:
				var has_pond := false
				var aq_count := 0
				for co in filtered:
					if co["type"] == "pond":
						has_pond = true
					elif co["type"] in AQUATIC:
						aq_count += 1
					else:
						return false
				if not has_pond or aq_count >= 2:
					return false
				continue
			
			if norm == "pond":
				for co in filtered:
					if not (co["type"] in AQUATIC):
						return false
				continue
			
			return false
	
	return true

func place(type_id: String, gx: int, gz: int, rot_step: int = 0, custom_id: String = "", extra_data: Dictionary = {}) -> Dictionary:
	_ensure_containers()
	var norm := Catalog.normalize_type(type_id)
	var item_def := Catalog.get_item(norm)
	if item_def.is_empty():
		return {}
	
	var footprint: Vector2i = item_def.get("size", Vector2i(1, 1))
	if not is_within_bounds(gx, gz, footprint):
		return {}
	
	var rot_rad := float(rot_step % 4) * (PI * 0.5)
	
	if item_def.get("is_ground", false):
		var key := "%d,%d" % [gx, gz]
		if ground_tiles.has(key):
			var old_entry: Dictionary = ground_tiles[key]
			if old_entry["type"] == norm and is_equal_approx(old_entry["rotation"], rot_rad):
				return old_entry
			if is_instance_valid(old_entry.get("node")):
				old_entry["node"].queue_free()
			ground_tiles.erase(key)
		
		var node := Catalog.instantiate_item(norm)
		if not node:
			return {}
		_ground_container.add_child(node)
		node.position = grid_to_world(gx, gz, Vector2i(1, 1))
		node.rotation = Vector3(0.0, rot_rad, 0.0)
		_animate_pop_in(node)
		
		var tile_id := custom_id if not custom_id.is_empty() else ("g_%d_%d" % [gx, gz])
		var entry := {
			"id": tile_id,
			"type": norm,
			"gx": gx,
			"gz": gz,
			"rotation": rot_rad,
			"size": 1,
			"node": node,
		}
		ground_tiles[key] = entry
		_sync_cell_states(gx, gz)
		object_placed.emit(entry)
		grid_changed.emit()
		return entry
	else:
		if not can_place(norm, gx, gz):
			return {}
		
		var node := Catalog.instantiate_item(norm)
		if not node:
			return {}
		_object_container.add_child(node)
		node.position = grid_to_world(gx, gz, footprint)
		node.rotation = Vector3(0.0, rot_rad, 0.0)
		
		if node is DioramaProp:
			var dp := node as DioramaProp
			dp.apply_night_mode(_is_night)
			if extra_data.has("gender"):
				dp.gender = str(extra_data["gender"])
			if extra_data.has("shirtColor"):
				dp.shirt_color = int(extra_data["shirtColor"])
				var sm: StandardMaterial3D = dp.refs.get("shirt_mat")
				if sm:
					var hc: int = dp.shirt_color
					sm.albedo_color = Color(float((hc >> 16) & 0xFF) / 255.0, float((hc >> 8) & 0xFF) / 255.0, float(hc & 0xFF) / 255.0)
			if extra_data.has("lampMode"):
				dp.set_lamp_mode(str(extra_data["lampMode"]))
			if extra_data.has("isSleeping") and bool(extra_data["isSleeping"]):
				dp.trigger_action("sleep_toggle", 0.0)
		
		_animate_pop_in(node)
		
		var obj_id := custom_id
		if obj_id.is_empty():
			obj_id = "obj_%d" % _next_id
			_next_id += 1
		
		var entry := {
			"id": obj_id,
			"type": norm,
			"gx": gx,
			"gz": gz,
			"rotation": rot_rad,
			"size": footprint.x,
			"node": node,
		}
		objects[obj_id] = entry
		
		for dx in range(footprint.x):
			for dz in range(footprint.y):
				var ckey := "%d,%d" % [gx + dx, gz + dz]
				if not _cell_occupancy.has(ckey):
					_cell_occupancy[ckey] = []
				_cell_occupancy[ckey].append(obj_id)
				_sync_cell_states(gx + dx, gz + dz)
		
		if norm in AUTOTILE_TYPES:
			_sync_neighbors()
		
		object_placed.emit(entry)
		grid_changed.emit()
		return entry

func remove_by_id(obj_id: String) -> Dictionary:
	if objects.has(obj_id):
		var entry: Dictionary = objects[obj_id]
		var gx: int = entry["gx"]
		var gz: int = entry["gz"]
		var sz: int = entry.get("size", 1)
		var was_autotile: bool = entry["type"] in AUTOTILE_TYPES
		if is_instance_valid(entry.get("node")):
			entry["node"].queue_free()
		objects.erase(obj_id)
		
		for dx in range(sz):
			for dz in range(sz):
				var ckey := "%d,%d" % [gx + dx, gz + dz]
				if _cell_occupancy.has(ckey):
					_cell_occupancy[ckey].erase(obj_id)
					if _cell_occupancy[ckey].is_empty():
						_cell_occupancy.erase(ckey)
				_sync_cell_states(gx + dx, gz + dz)
		
		if was_autotile:
			_sync_neighbors()
		
		object_removed.emit(entry)
		grid_changed.emit()
		return entry
	return {}

func remove_at(gx: int, gz: int) -> Dictionary:
	var top_obj := get_primary_object_at(gx, gz)
	if not top_obj.is_empty():
		return remove_by_id(top_obj["id"])
	
	var key := "%d,%d" % [gx, gz]
	if ground_tiles.has(key):
		var entry: Dictionary = ground_tiles[key]
		if is_instance_valid(entry.get("node")):
			entry["node"].queue_free()
		ground_tiles.erase(key)
		_sync_cell_states(gx, gz)
		object_removed.emit(entry)
		grid_changed.emit()
		return entry
	
	return {}

func apply_night_mode(night: bool) -> void:
	_is_night = night
	for obj in objects.values():
		var node: Node3D = obj.get("node")
		if is_instance_valid(node) and node.has_method("apply_night_mode"):
			node.call("apply_night_mode", night)

func _sync_cell_states(gx: int, gz: int) -> void:
	var cell_objs := get_objects_at(gx, gz)
	var ground := get_ground_at(gx, gz)
	var is_water_ground: bool = ground.get("type", "") == "water"
	
	var seat_entry: Dictionary = {}
	var perch_entry: Dictionary = {}
	var has_pond: bool = false
	var sitters_list: Array[Dictionary] = []
	var perchers_list: Array[Dictionary] = []
	
	for co in cell_objs:
		var t: String = co["type"]
		if t in SEATS:
			seat_entry = co
		elif t in PERCHES:
			perch_entry = co
		elif t == "pond":
			has_pond = true
		if t in SITTERS:
			sitters_list.append(co)
		elif t in PERCHERS:
			perchers_list.append(co)
	
	var world_center := grid_to_world(gx, gz, Vector2i(1, 1))
	
	# 1. Position and pose sitters on bench (up to 2) or beertable (up to 4)
	for idx in range(sitters_list.size()):
		var co: Dictionary = sitters_list[idx]
		var node: Node3D = co.get("node")
		if not is_instance_valid(node):
			continue
		if not seat_entry.is_empty():
			var seat_rot: float = seat_entry.get("rotation", 0.0)
			if seat_entry["type"] == "bench":
				var side_offset := 0.0 if sitters_list.size() == 1 else (-0.19 if idx == 0 else 0.19)
				var local_off := Vector3(side_offset, 0.0, 0.04).rotated(Vector3.UP, seat_rot)
				node.position = world_center + local_off
				node.rotation.y = seat_rot
				if node.has_method("set_sitting"):
					node.call("set_sitting", true, 0.18)
			elif seat_entry["type"] == "beertable":
				var slot_offsets := [
					Vector3(-0.18, 0.0, 0.28),
					Vector3(0.18, 0.0, 0.28),
					Vector3(-0.18, 0.0, -0.28),
					Vector3(0.18, 0.0, -0.28),
				]
				var slot_rots := [PI, PI, 0.0, 0.0]
				var s_idx := idx % 4
				var local_off := (slot_offsets[s_idx] as Vector3).rotated(Vector3.UP, seat_rot)
				node.position = world_center + local_off
				node.rotation.y = seat_rot + float(slot_rots[s_idx])
				if node.has_method("set_sitting"):
					node.call("set_sitting", true, 0.16)
		else:
			node.position = world_center
			if node.has_method("set_sitting"):
				node.call("set_sitting", false, 0.0)
	
	# 2. Position and pose perchers (parrot, squirrel) on tree, pine, or streetlamp
	for idx in range(perchers_list.size()):
		var co: Dictionary = perchers_list[idx]
		var node: Node3D = co.get("node")
		if not is_instance_valid(node):
			continue
		if not perch_entry.is_empty():
			var p_type: String = perch_entry["type"]
			var perch_y := 1.15
			var off := Vector3(0.14 if idx == 0 else -0.14, 0.0, 0.08)
			if p_type == "streetlamp":
				perch_y = 1.44
				off = Vector3(0.0, 0.0, 0.18 if idx == 0 else 0.0)
			elif p_type == "pine":
				perch_y = 1.12
				off = Vector3(0.16 if idx == 0 else -0.16, 0.0, 0.12)
			else:
				perch_y = 0.65 if idx == 0 else 1.22
				off = Vector3(0.18 if idx == 0 else -0.12, 0.0, 0.06)
			node.position = world_center + off
			if node.has_method("set_perched"):
				node.call("set_perched", true, perch_y)
		else:
			node.position = world_center
			if node.has_method("set_perched"):
				node.call("set_perched", false, 0.0)
	
	# 3. Aquatic creatures (duck, axolotl) on water or pond
	for co in cell_objs:
		if co["type"] in AQUATIC:
			var node: Node3D = co.get("node")
			if is_instance_valid(node) and node.has_method("set_floating"):
				node.call("set_floating", is_water_ground or has_pond)

func _sync_neighbors() -> void:
	for obj in objects.values():
		var t: String = obj["type"]
		if not (t in AUTOTILE_TYPES):
			continue
		var node: Node3D = obj.get("node")
		if not is_instance_valid(node) or not node.has_method("update_connections"):
			continue
		var gx: int = obj["gx"]
		var gz: int = obj["gz"]
		var step: int = obj.get("size", 1)
		var rot: float = obj.get("rotation", 0.0)
		
		var world_dirs := {
			"n": _has_object_of_type_at(t, gx, gz - step, obj["id"]),
			"s": _has_object_of_type_at(t, gx, gz + step, obj["id"]),
			"e": _has_object_of_type_at(t, gx + step, gz, obj["id"]),
			"w": _has_object_of_type_at(t, gx - step, gz, obj["id"]),
		}
		# Rotate world directions into local object space
		var rot_steps := int(round(rot / (PI * 0.5))) % 4
		if rot_steps < 0:
			rot_steps += 4
		var order := ["n", "e", "s", "w"]
		var local_mask := {}
		for i in range(4):
			var world_idx := (i + rot_steps) % 4
			local_mask[order[i]] = world_dirs[order[world_idx]]
		node.call("update_connections", local_mask)

func _has_object_of_type_at(type_id: String, gx: int, gz: int, exclude_id: String) -> bool:
	var objs := get_objects_at(gx, gz)
	for o in objs:
		if o["id"] != exclude_id and o["type"] == type_id:
			return true
	return false

func resize_grid(new_size: int) -> void:
	new_size = clampi(new_size, 4, 32)
	if new_size == grid_size:
		return
	var offset := int(floor(float(new_size - grid_size) * 0.5))
	var old_ground := ground_tiles.values()
	var old_objects := objects.values()
	
	clear(false)
	grid_size = new_size
	
	for g in old_ground:
		var ngx: int = g["gx"] + offset
		var ngz: int = g["gz"] + offset
		if is_within_bounds(ngx, ngz, Vector2i(1, 1)):
			var rot_step := int(round(float(g["rotation"]) / (PI * 0.5))) % 4
			place(g["type"], ngx, ngz, rot_step, g["id"])
	
	for o in old_objects:
		var item_def := Catalog.get_item(o["type"])
		var fp: Vector2i = item_def.get("size", Vector2i(1, 1))
		var ngx: int = o["gx"] + offset
		var ngz: int = o["gz"] + offset
		if is_within_bounds(ngx, ngz, fp):
			var rot_step := int(round(float(o["rotation"]) / (PI * 0.5))) % 4
			place(o["type"], ngx, ngz, rot_step, o["id"])
	
	grid_changed.emit()

func clear(emit_signal_flag: bool = true) -> void:
	for entry in ground_tiles.values():
		if is_instance_valid(entry.get("node")):
			entry["node"].queue_free()
	for entry in objects.values():
		if is_instance_valid(entry.get("node")):
			entry["node"].queue_free()
	ground_tiles.clear()
	objects.clear()
	_cell_occupancy.clear()
	if emit_signal_flag:
		grid_changed.emit()

func get_state_snapshot() -> Dictionary:
	return DioramaSerializer.serialize(self)

func restore_state_snapshot(snapshot: Dictionary) -> void:
	DioramaSerializer.deserialize_from_dict(snapshot, self)

func _animate_pop_in(node: Node3D) -> void:
	if not is_inside_tree():
		return
	node.scale = Vector3(0.01, 0.01, 0.01)
	var tween := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "scale", Vector3.ONE, 0.22)
