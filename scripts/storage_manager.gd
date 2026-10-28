class_name StorageManager
extends Node

## Handles local persistence (`user://diorama_save.json`), 5-slot snapshots (`user://diorama_snapshots.json`),
## harvest basket persistence (`user://diorama_basket.json`), and auto-save debouncing.

signal save_status_changed(status: String) # "saving", "saved", "loaded", "error"

const SAVE_PATH: String = "user://diorama_save.json"
const SNAPSHOTS_PATH: String = "user://diorama_snapshots.json"
const BASKET_PATH: String = "user://diorama_basket.json"

@export var grid_manager: GridManager
@export var auto_save_delay: float = 0.8

var _auto_save_timer: Timer
var _pending_save: bool = false

func _ready() -> void:
	_auto_save_timer = Timer.new()
	_auto_save_timer.one_shot = true
	_auto_save_timer.timeout.connect(_on_auto_save_timeout)
	add_child(_auto_save_timer)
	
	if grid_manager:
		grid_manager.grid_changed.connect(_on_grid_changed)

func save_local() -> bool:
	if not grid_manager:
		return false
	
	save_status_changed.emit("saving")
	var json_str := DioramaSerializer.serialize_to_json(grid_manager, true)
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if not file:
		var err := FileAccess.get_open_error()
		push_error("Failed to write save file %s: error %d" % [SAVE_PATH, err])
		save_status_changed.emit("error")
		return false
	
	file.store_string(json_str)
	file.close()
	_pending_save = false
	save_status_changed.emit("saved")
	return true

func load_local() -> bool:
	if not grid_manager or not has_save_file():
		return false
	
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return false
	
	var json_str := file.get_as_text()
	file.close()
	
	var json := JSON.new()
	if json.parse(json_str) != OK or not (json.data is Dictionary):
		return false
	
	var data: Dictionary = json.data
	# Migrate old v1 starter saves that lacked schemaVersion 2
	if int(data.get("schemaVersion", 1)) < DioramaSerializer.CURRENT_SCHEMA_VERSION:
		return false
	
	var success := DioramaSerializer.deserialize_from_dict(data, grid_manager)
	if success:
		save_status_changed.emit("loaded")
	return success

func has_save_file() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func save_basket(basket: Dictionary) -> void:
	var file := FileAccess.open(BASKET_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(basket))
		file.close()

func load_basket() -> Dictionary:
	var default_basket := {"strawberry": 0, "potato": 0, "mushroom": 0, "nut": 0}
	if not FileAccess.file_exists(BASKET_PATH):
		return default_basket
	var file := FileAccess.open(BASKET_PATH, FileAccess.READ)
	if not file:
		return default_basket
	var json := JSON.new()
	if json.parse(file.get_as_text()) == OK and json.data is Dictionary:
		for k in default_basket:
			if json.data.has(k):
				default_basket[k] = max(0, int(json.data[k]))
	file.close()
	return default_basket

func load_snapshots() -> Array:
	var slots := [null, null, null, null, null]
	if not FileAccess.file_exists(SNAPSHOTS_PATH):
		return slots
	var file := FileAccess.open(SNAPSHOTS_PATH, FileAccess.READ)
	if not file:
		return slots
	var json := JSON.new()
	if json.parse(file.get_as_text()) == OK and json.data is Array:
		for i in range(min(5, json.data.size())):
			slots[i] = json.data[i]
	file.close()
	return slots

func save_snapshot_slot(slot_idx: int, slot_name: String = "") -> bool:
	if slot_idx < 0 or slot_idx >= 5 or not grid_manager:
		return false
	var slots := load_snapshots()
	var state := DioramaSerializer.serialize(grid_manager)
	var obj_count: int = (state.get("objects", []) as Array).size()
	var tile_count: int = (state.get("ground", []) as Array).size()
	var dt := Time.get_datetime_dict_from_system()
	var timestamp := "%02d.%02d.%04d %02d:%02d" % [dt["day"], dt["month"], dt["year"], dt["hour"], dt["minute"]]
	slots[slot_idx] = {
		"name": slot_name if not slot_name.is_empty() else ("Slot %d" % (slot_idx + 1)),
		"timestamp": timestamp,
		"gridSize": grid_manager.grid_size,
		"objectCount": obj_count,
		"tileCount": tile_count,
		"state": state,
	}
	var file := FileAccess.open(SNAPSHOTS_PATH, FileAccess.WRITE)
	if not file:
		return false
	file.store_string(JSON.stringify(slots, "\t"))
	file.close()
	return true

func load_snapshot_slot(slot_idx: int) -> bool:
	var slots := load_snapshots()
	if slot_idx < 0 or slot_idx >= 5 or slots[slot_idx] == null:
		return false
	var entry = slots[slot_idx]
	if entry is Dictionary and entry.has("state") and entry["state"] is Dictionary:
		var ok := DioramaSerializer.deserialize_from_dict(entry["state"], grid_manager)
		if ok:
			save_local()
		return ok
	return false

func delete_snapshot_slot(slot_idx: int) -> bool:
	var slots := load_snapshots()
	if slot_idx < 0 or slot_idx >= 5:
		return false
	slots[slot_idx] = null
	var file := FileAccess.open(SNAPSHOTS_PATH, FileAccess.WRITE)
	if not file:
		return false
	file.store_string(JSON.stringify(slots, "\t"))
	file.close()
	return true

func _on_grid_changed() -> void:
	_pending_save = true
	save_status_changed.emit("saving")
	if _auto_save_timer:
		_auto_save_timer.start(auto_save_delay)

func _on_auto_save_timeout() -> void:
	if _pending_save:
		save_local()
