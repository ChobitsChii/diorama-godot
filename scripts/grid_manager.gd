class_name GridManager
extends Node3D

## Manages diorama grid coordinate mapping, cell occupancy, placement, selection, lift animation, and demolition.

signal grid_changed()
signal item_placed(entry: Dictionary)
signal item_removed(entry: Dictionary)

@export var grid_size: int = 12
@export var cell_size: float = 1.0

# 2-Layer data hierarchy:
# Layer 0 (Ground tiles): Vector2i(gx, gz) -> { id, type, gx, gz, rot_step, node, is_ground: true }
var ground_tiles: Dictionary = {}

# Layer 1 (Objects / Props): object_id -> { id, type, gx, gz, rot_step, size, node, is_ground: false, base_y: float }
var objects: Dictionary = {}

# Occupancy grid for props: Vector2i(gx, gz) -> object_id
var cells: Dictionary = {}

var _next_id: int = 1

func _ready() -> void:
	pass

func set_grid_size(new_size: int) -> void:
	grid_size = new_size
	update_all_item_positions()
	grid_changed.emit()

func update_all_item_positions() -> void:
	for entry in ground_tiles.values():
		if entry.get("node") and is_instance_valid(entry["node"]):
			var pos = grid_to_world(entry["gx"], entry["gz"], 1)
			pos.y = entry.get("base_y", 0.0)
			entry["node"].position = pos
	for entry in objects.values():
		if entry.get("node") and is_instance_valid(entry["node"]):
			var pos = grid_to_world(entry["gx"], entry["gz"], entry.get("size", 1))
			pos.y = entry.get("base_y", 0.0)
			entry["node"].position = pos

# -----------------------------------------------------------------------------
# Coordinate Conversions
# -----------------------------------------------------------------------------
func grid_to_world(gx: int, gz: int, item_size: int = 1) -> Vector3:
	var half: float = (float(grid_size) * cell_size) * 0.5
	var offset: float = (float(item_size) * cell_size) * 0.5
	return Vector3(
		float(gx) * cell_size - half + offset,
		0.0,
		float(gz) * cell_size - half + offset
	)

func world_to_grid(world_pos: Vector3, item_size: int = 1) -> Vector2i:
	var half: float = (float(grid_size) * cell_size) * 0.5
	var offset: float = (float(item_size) * cell_size) * 0.5
	var gx: int = int(round((world_pos.x + half - offset) / cell_size))
	var gz: int = int(round((world_pos.z + half - offset) / cell_size))
	return Vector2i(gx, gz)

func is_in_bounds(gx: int, gz: int, item_size: int = 1) -> bool:
	return gx >= 0 and gz >= 0 and (gx + item_size) <= grid_size and (gz + item_size) <= grid_size

func is_valid_position(gx: int, gz: int, item_size: int, type_id: String) -> bool:
	if not is_in_bounds(gx, gz, item_size):
		return false
	
	var item_def = Catalog.get_item(type_id)
	var is_ground = item_def.get("is_ground", false)
	
	# Ground tiles can always be placed or replaced on any valid grid cell
	if is_ground:
		return true
	
	# Special case: Creatures (e.g. cat) can be placed on a bench
	if type_id == "cat":
		var bench_obj = get_object_at(gx, gz)
		if not bench_obj.is_empty() and bench_obj["type"] == "bench":
			return true
	
	# For regular objects, ensure no overlapping cells
	for x in range(item_size):
		for z in range(item_size):
			var cell_pos = Vector2i(gx + x, gz + z)
			if cells.has(cell_pos):
				return false
	
	return true

# -----------------------------------------------------------------------------
# Placement & Removal
# -----------------------------------------------------------------------------
func place(type_id: String, gx: int, gz: int, rot_step: int = 0, custom_id: String = "") -> Dictionary:
	var item_def = Catalog.get_item(type_id)
	if item_def.is_empty():
		push_warning("Unknown catalog item: %s" % type_id)
		return {}
	
	var item_size: int = item_def.get("size", 1)
	var is_ground: bool = item_def.get("is_ground", false)
	
	var id: String = custom_id
	if id.is_empty():
		id = "%s_%d" % [type_id, _next_id]
		_next_id += 1
	
	var world_pos = grid_to_world(gx, gz, item_size)
	var node = Catalog.instantiate_item(type_id)
	if not node:
		push_warning("Failed to instantiate catalog scene for %s" % type_id)
		return {}
	
	var rot_rad = float(rot_step) * (PI * 0.5)
	node.rotation.y = rot_rad
	
	# Layer 0: Ground tile
	if is_ground:
		var cell_key = Vector2i(gx, gz)
		if ground_tiles.has(cell_key):
			var existing = ground_tiles[cell_key]
			if existing.get("node") and is_instance_valid(existing["node"]):
				existing["node"].queue_free()
			ground_tiles.erase(cell_key)
		
		node.position = world_pos
		add_child(node)
		
		var ground_entry = {
			"id": id,
			"type": type_id,
			"gx": gx,
			"gz": gz,
			"rot_step": rot_step,
			"rotation": rot_rad,
			"size": 1,
			"node": node,
			"is_ground": true,
			"base_y": 0.0,
		}
		ground_tiles[cell_key] = ground_entry
		animate_spawn(node)
		grid_changed.emit()
		item_placed.emit(ground_entry)
		return ground_entry
	
	# Layer 1: Object / Building / Creature / Deco
	var base_y: float = 0.0
	
	# Bench snapping for Cat
	if type_id == "cat":
		var bench_obj = get_object_at(gx, gz)
		if not bench_obj.is_empty() and bench_obj["type"] == "bench":
			base_y = 0.28
	
	node.position = Vector3(world_pos.x, base_y, world_pos.z)
	add_child(node)
	
	var entry = {
		"id": id,
		"type": type_id,
		"gx": gx,
		"gz": gz,
		"rot_step": rot_step,
		"rotation": rot_rad,
		"size": item_size,
		"node": node,
		"is_ground": false,
		"base_y": base_y,
	}
	objects[id] = entry
	
	# Register occupied cells
	for x in range(item_size):
		for z in range(item_size):
			cells[Vector2i(gx + x, gz + z)] = id
	
	animate_spawn(node)
	grid_changed.emit()
	item_placed.emit(entry)
	return entry

func remove_object(id: String) -> bool:
	if not objects.has(id):
		return false
	var entry = objects[id]
	var item_size: int = entry.get("size", 1)
	
	for x in range(item_size):
		for z in range(item_size):
			cells.erase(Vector2i(entry["gx"] + x, entry["gz"] + z))
	
	if entry.get("node") and is_instance_valid(entry["node"]):
		animate_despawn(entry["node"])
	
	objects.erase(id)
	grid_changed.emit()
	item_removed.emit(entry)
	return true

func remove_ground_at(gx: int, gz: int) -> bool:
	var key = Vector2i(gx, gz)
	if not ground_tiles.has(key):
		return false
	var entry = ground_tiles[key]
	if entry.get("node") and is_instance_valid(entry["node"]):
		animate_despawn(entry["node"])
	ground_tiles.erase(key)
	grid_changed.emit()
	item_removed.emit(entry)
	return true

func demolish_at(gx: int, gz: int) -> bool:
	# Priority: Demolish prop on top first; if empty, demolish ground tile
	var obj = get_object_at(gx, gz)
	if not obj.is_empty():
		return remove_object(obj["id"])
	var ground = get_ground_at(gx, gz)
	if not ground.is_empty():
		return remove_ground_at(gx, gz)
	return false

# -----------------------------------------------------------------------------
# Lookups & Helpers
# -----------------------------------------------------------------------------
func get_object_at(gx: int, gz: int) -> Dictionary:
	var key = Vector2i(gx, gz)
	if cells.has(key):
		var id = cells[key]
		return objects.get(id, {})
	return {}

func get_ground_at(gx: int, gz: int) -> Dictionary:
	return ground_tiles.get(Vector2i(gx, gz), {})

func get_top_item_at(gx: int, gz: int) -> Dictionary:
	var obj = get_object_at(gx, gz)
	if not obj.is_empty():
		return obj
	return get_ground_at(gx, gz)

# -----------------------------------------------------------------------------
# Move & Rotation
# -----------------------------------------------------------------------------
func move_item(entry: Dictionary, new_gx: int, new_gz: int) -> bool:
	var item_size: int = entry.get("size", 1)
	var is_ground: bool = entry.get("is_ground", false)
	
	if entry["gx"] == new_gx and entry["gz"] == new_gz:
		return false
	
	if not is_in_bounds(new_gx, new_gz, item_size):
		return false
	
	if is_ground:
		var old_key = Vector2i(entry["gx"], entry["gz"])
		var new_key = Vector2i(new_gx, new_gz)
		
		# If destination has a ground tile, swap positions
		if ground_tiles.has(new_key):
			var other = ground_tiles[new_key]
			other["gx"] = entry["gx"]
			other["gz"] = entry["gz"]
			var other_world = grid_to_world(entry["gx"], entry["gz"], 1)
			if other.get("node") and is_instance_valid(other["node"]):
				other["node"].position = other_world
			ground_tiles[old_key] = other
		else:
			ground_tiles.erase(old_key)
		
		entry["gx"] = new_gx
		entry["gz"] = new_gz
		ground_tiles[new_key] = entry
		
		var ground_target_pos = grid_to_world(new_gx, new_gz, 1)
		if entry.get("node") and is_instance_valid(entry["node"]):
			var tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			tween.tween_property(entry["node"], "position", ground_target_pos, 0.15)
		
		grid_changed.emit()
		return true
	
	# For objects, unregister old cells temporarily to check validity
	for x in range(item_size):
		for z in range(item_size):
			cells.erase(Vector2i(entry["gx"] + x, entry["gz"] + z))
	
	if not is_valid_position(new_gx, new_gz, item_size, entry["type"]):
		# Restore old cells
		for x in range(item_size):
			for z in range(item_size):
				cells[Vector2i(entry["gx"] + x, entry["gz"] + z)] = entry["id"]
		return false
	
	entry["gx"] = new_gx
	entry["gz"] = new_gz
	for x in range(item_size):
		for z in range(item_size):
			cells[Vector2i(new_gx + x, new_gz + z)] = entry["id"]
	
	var base_y: float = 0.0
	if entry["type"] == "cat":
		var bench_obj = get_object_at(new_gx, new_gz)
		if not bench_obj.is_empty() and bench_obj["type"] == "bench":
			base_y = 0.28
	entry["base_y"] = base_y
	
	var world_pos = grid_to_world(new_gx, new_gz, item_size)
	world_pos.y = base_y
	if entry.get("node") and is_instance_valid(entry["node"]):
		var tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(entry["node"], "position", world_pos, 0.15)
	
	grid_changed.emit()
	return true

func rotate_item(entry: Dictionary, step_delta: int = 1) -> int:
	var new_step = (entry.get("rot_step", 0) + step_delta) % 4
	entry["rot_step"] = new_step
	var rot_rad = float(new_step) * (PI * 0.5)
	entry["rotation"] = rot_rad
	
	if entry.get("node") and is_instance_valid(entry["node"]):
		var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(entry["node"], "rotation:y", rot_rad, 0.2)
	
	grid_changed.emit()
	return new_step

# -----------------------------------------------------------------------------
# Lift Animations (Pick-up & Drop)
# -----------------------------------------------------------------------------
func lift_item(entry: Dictionary, lift_height: float = 0.35) -> void:
	if not entry.get("node") or not is_instance_valid(entry["node"]):
		return
	var base_y: float = entry.get("base_y", 0.0)
	var target_y = base_y + lift_height
	var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(entry["node"], "position:y", target_y, 0.22)

func drop_item(entry: Dictionary) -> void:
	if not entry.get("node") or not is_instance_valid(entry["node"]):
		return
	var base_y: float = entry.get("base_y", 0.0)
	var tween = create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tween.tween_property(entry["node"], "position:y", base_y, 0.28)

func animate_spawn(node: Node3D) -> void:
	node.scale = Vector3(0.01, 0.01, 0.01)
	var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "scale", Vector3.ONE, 0.26)

func animate_despawn(node: Node3D) -> void:
	var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_property(node, "scale", Vector3(0.01, 0.01, 0.01), 0.18)
	tween.tween_callback(node.queue_free)

func clear() -> void:
	for entry in objects.values():
		if entry.get("node") and is_instance_valid(entry["node"]):
			entry["node"].queue_free()
	for entry in ground_tiles.values():
		if entry.get("node") and is_instance_valid(entry["node"]):
			entry["node"].queue_free()
	objects.clear()
	ground_tiles.clear()
	cells.clear()
	grid_changed.emit()
