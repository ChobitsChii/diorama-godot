class_name HistoryManager
extends Node

## Handles Undo and Redo operations using serialized snapshot states.

signal history_changed(can_undo: bool, can_redo: bool)

@export var grid_manager: GridManager
@export var max_history: int = 20

var _undo_stack: Array[Dictionary] = []
var _redo_stack: Array[Dictionary] = []
var _is_restoring: bool = false

func _ready() -> void:
	if grid_manager:
		grid_manager.grid_changed.connect(_on_grid_changed)
	history_changed.emit(false, false)

func record_state_before_action() -> void:
	if _is_restoring or not grid_manager:
		return
	var snapshot = DioramaSerializer.serialize(grid_manager)
	_undo_stack.append(snapshot)
	if _undo_stack.size() > max_history:
		_undo_stack.pop_front()
	_redo_stack.clear()
	history_changed.emit(can_undo(), can_redo())

func undo() -> bool:
	if not can_undo() or not grid_manager:
		return false
	
	_is_restoring = true
	var current_state = DioramaSerializer.serialize(grid_manager)
	_redo_stack.append(current_state)
	
	var previous_state = _undo_stack.pop_back()
	DioramaSerializer.deserialize_from_dict(previous_state, grid_manager)
	_is_restoring = false
	
	history_changed.emit(can_undo(), can_redo())
	return true

func redo() -> bool:
	if not can_redo() or not grid_manager:
		return false
	
	_is_restoring = true
	var current_state = DioramaSerializer.serialize(grid_manager)
	_undo_stack.append(current_state)
	
	var next_state = _redo_stack.pop_back()
	DioramaSerializer.deserialize_from_dict(next_state, grid_manager)
	_is_restoring = false
	
	history_changed.emit(can_undo(), can_redo())
	return true

func can_undo() -> bool:
	return _undo_stack.size() > 0

func can_redo() -> bool:
	return _redo_stack.size() > 0

func clear() -> void:
	_undo_stack.clear()
	_redo_stack.clear()
	history_changed.emit(false, false)

func reset() -> void:
	clear()

func _on_grid_changed() -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.ctrl_pressed:
			if event.keycode == KEY_Z:
				if event.shift_pressed:
					redo()
				else:
					undo()
				get_viewport().set_input_as_handled()
			elif event.keycode == KEY_Y:
				redo()
				get_viewport().set_input_as_handled()
