class_name DioramaSerializer
extends RefCounted

## Serializes and rehydrates diorama scenes to/from the Modulon JSON specification.

static func serialize(grid_mgr: GridManager) -> Dictionary:
	var state = {
		"gridSize": grid_mgr.grid_size,
		"ground": [],
		"objects": [],
	}
	
	# Serialize ground tiles (Layer 0)
	for tile in grid_mgr.ground_tiles.values():
		state["ground"].append({
			"id": tile.get("id", ""),
			"type": Catalog.normalize_type(tile.get("type", "grass")),
			"gx": tile.get("gx", 0),
			"gz": tile.get("gz", 0),
			"rotation": tile.get("rotation", 0.0),
		})
	
	# Serialize objects / props (Layer 1)
	for obj in grid_mgr.objects.values():
		state["objects"].append({
			"id": obj.get("id", ""),
			"type": Catalog.normalize_type(obj.get("type", "")),
			"gx": obj.get("gx", 0),
			"gz": obj.get("gz", 0),
			"rotation": obj.get("rotation", 0.0),
			"size": obj.get("size", 1),
		})
	
	return state

static func serialize_to_json(grid_mgr: GridManager, indent: bool = true) -> String:
	var dict = serialize(grid_mgr)
	return JSON.stringify(dict, "\t" if indent else "")

static func deserialize_from_dict(data: Dictionary, grid_mgr: GridManager) -> bool:
	if not data.has("gridSize") and not data.has("ground") and not data.has("objects"):
		push_warning("Invalid diorama data: missing standard fields")
		return false
	
	grid_mgr.clear()
	
	if data.has("gridSize"):
		var new_size = int(data["gridSize"])
		if new_size > 0:
			grid_mgr.grid_size = new_size
	
	# Rehydrate ground tiles (Layer 0)
	if data.has("ground") and data["ground"] is Array:
		for item in data["ground"]:
			if item is Dictionary:
				var raw_type: String = item.get("type", "grass")
				var type_id = Catalog.normalize_type(raw_type)
				var gx: int = int(item.get("gx", 0))
				var gz: int = int(item.get("gz", 0))
				var rot_val = item.get("rotation", 0.0)
				var rot_step: int = 0
				if typeof(rot_val) == TYPE_INT:
					rot_step = rot_val % 4
				else:
					rot_step = int(round(float(rot_val) / (PI * 0.5))) % 4
				var custom_id: String = item.get("id", "")
				grid_mgr.place(type_id, gx, gz, rot_step, custom_id)
	
	# Rehydrate objects / props (Layer 1)
	if data.has("objects") and data["objects"] is Array:
		for item in data["objects"]:
			if item is Dictionary:
				var raw_type: String = item.get("type", "")
				var type_id = Catalog.normalize_type(raw_type)
				var gx: int = int(item.get("gx", 0))
				var gz: int = int(item.get("gz", 0))
				var rot_val = item.get("rotation", 0.0)
				var rot_step: int = 0
				if typeof(rot_val) == TYPE_INT:
					rot_step = rot_val % 4
				else:
					rot_step = int(round(float(rot_val) / (PI * 0.5))) % 4
				var custom_id: String = item.get("id", "")
				grid_mgr.place(type_id, gx, gz, rot_step, custom_id)
	
	return true

static func deserialize_from_json(json_str: String, grid_mgr: GridManager) -> bool:
	var json = JSON.new()
	var error = json.parse(json_str)
	if error != OK:
		push_error("JSON Parse Error: %s at line %d" % [json.get_error_message(), json.get_error_line()])
		return false
	
	var data = json.data
	if data is Dictionary:
		return deserialize_from_dict(data, grid_mgr)
	return false
