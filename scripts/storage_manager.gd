class_name StorageManager
extends Node

## Handles local persistence (user://diorama_save.json) and auto-save debouncing.

signal save_status_changed(status: String) # "saving", "saved", "error"

const SAVE_PATH: String = "user://diorama_save.json"

@export var grid_manager: GridManager
@export var auto_save_delay: float = 1.0

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
	var json_str = DioramaSerializer.serialize_to_json(grid_manager, true)
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if not file:
		var err = FileAccess.get_open_error()
		push_error("Failed to write save file %s: error %d" % [SAVE_PATH, err])
		save_status_changed.emit("error")
		return false
	
	file.store_string(json_str)
	file.close()
	_pending_save = false
	save_status_changed.emit("saved")
	return true

func load_local() -> bool:
	if not grid_manager:
		return false
	
	if not has_save_file():
		return false
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return false
	
	var json_str = file.get_as_text()
	file.close()
	
	var success = DioramaSerializer.deserialize_from_json(json_str, grid_manager)
	if success:
		save_status_changed.emit("loaded")
	return success

func has_save_file() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func _on_grid_changed() -> void:
	_pending_save = true
	if _auto_save_timer:
		_auto_save_timer.start(auto_save_delay)

func _on_auto_save_timeout() -> void:
	if _pending_save:
		save_local()
