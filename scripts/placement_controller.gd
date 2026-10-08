class_name PlacementController
extends Node3D

## Handles 3D raycasting, tool modes (Select, Place, Demolish), ghost mesh preview, and user interactions.

signal mode_changed(new_mode: int)
signal selection_changed(has_selection: bool, entry: Dictionary)
signal item_placed(entry: Dictionary)
signal creature_interacted(creature_id: String, speech: String, pos: Vector3)

enum Mode {
	EXPLORE = 0,
	SELECT = 1,
	PLACE = 2,
	DEMOLISH = 3,
}

@export var grid_manager: GridManager
@export var camera: Camera3D
@export var history_manager: HistoryManager

var current_mode: Mode = Mode.EXPLORE

# Active placement tool state
var active_type_id: String = "cottage"
var active_place_type: String:
	get:
		return active_type_id
	set(value):
		set_active_place_type(value)
var active_rot_step: int = 0
var _ghost_root: Node3D

# Active selection tool state
var selected_entry: Dictionary = {}
var _original_gx: int = 0
var _original_gz: int = 0

# Hover state
var hovered_cell: Vector2i = Vector2i(-1, -1)
var is_pointer_on_grid: bool = false

# Visual materials for ghost
var _valid_ghost_mat: StandardMaterial3D
var _invalid_ghost_mat: StandardMaterial3D
var _demolish_ghost_mat: StandardMaterial3D

func _ready() -> void:
	_init_materials()
	_create_ghost_root()
	set_mode(Mode.EXPLORE)

func _init_materials() -> void:
	_valid_ghost_mat = StandardMaterial3D.new()
	_valid_ghost_mat.albedo_color = Color(0.28, 0.73, 0.47, 0.55)
	_valid_ghost_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_valid_ghost_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	
	_invalid_ghost_mat = StandardMaterial3D.new()
	_invalid_ghost_mat.albedo_color = Color(0.94, 0.27, 0.27, 0.55)
	_invalid_ghost_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_invalid_ghost_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	
	_demolish_ghost_mat = StandardMaterial3D.new()
	_demolish_ghost_mat.albedo_color = Color(0.94, 0.15, 0.15, 0.65)
	_demolish_ghost_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_demolish_ghost_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED

func _create_ghost_root() -> void:
	if not _ghost_root:
		_ghost_root = Node3D.new()
		_ghost_root.name = "GhostRoot"
		add_child(_ghost_root)
		_ghost_root.visible = false

# -----------------------------------------------------------------------------
# Mode & Tool Switching
# -----------------------------------------------------------------------------
func set_mode(mode: Mode) -> void:
	if current_mode == Mode.SELECT and not selected_entry.is_empty() and mode != Mode.SELECT:
		cancel_selection()
	
	current_mode = mode
	_update_ghost_template()
	mode_changed.emit(current_mode)

func set_active_place_type(type_id: String) -> void:
	active_type_id = type_id
	set_mode(Mode.PLACE)

func rotate_active() -> void:
	if current_mode == Mode.SELECT and not selected_entry.is_empty():
		if history_manager:
			history_manager.record_state_before_action()
		grid_manager.rotate_item(selected_entry)
	elif current_mode == Mode.PLACE:
		active_rot_step = (active_rot_step + 1) % 4
		if _ghost_root:
			_ghost_root.rotation.y = float(active_rot_step) * (PI * 0.5)

# -----------------------------------------------------------------------------
# Ghost Mesh Management
# -----------------------------------------------------------------------------
func _update_ghost_template() -> void:
	if not _ghost_root:
		return
	
	# Clear existing ghost children
	for child in _ghost_root.get_children():
		child.queue_free()
	
	if current_mode == Mode.PLACE:
		var preview_node = Catalog.instantiate_item(active_type_id)
		if preview_node:
			_apply_ghost_materials(preview_node, _valid_ghost_mat)
			_ghost_root.add_child(preview_node)
			_ghost_root.rotation.y = float(active_rot_step) * (PI * 0.5)
			_ghost_root.visible = true
	elif current_mode == Mode.DEMOLISH:
		var box = MeshInstance3D.new()
		var b_mesh = BoxMesh.new()
		b_mesh.size = Vector3(1.0, 0.3, 1.0)
		b_mesh.material = _demolish_ghost_mat
		box.mesh = b_mesh
		box.position.y = 0.1
		_ghost_root.add_child(box)
		_ghost_root.visible = true
	else:
		_ghost_root.visible = false

func _apply_ghost_materials(node: Node, mat: StandardMaterial3D) -> void:
	if node is MeshInstance3D:
		var mesh_inst = node as MeshInstance3D
		for i in range(mesh_inst.get_surface_override_material_count()):
			mesh_inst.set_surface_override_material(i, mat)
		if mesh_inst.get_surface_override_material_count() == 0:
			mesh_inst.material_override = mat
	
	for child in node.get_children():
		_apply_ghost_materials(child, mat)

func _update_ghost_validity(is_valid: bool) -> void:
	if current_mode == Mode.PLACE and _ghost_root:
		var target_mat = _valid_ghost_mat if is_valid else _invalid_ghost_mat
		_apply_ghost_materials(_ghost_root, target_mat)

# -----------------------------------------------------------------------------
# Input & Raycasting
# -----------------------------------------------------------------------------
func _process(_delta: float) -> void:
	_update_raycast()

func _update_raycast() -> void:
	if not camera or not grid_manager:
		return
	
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_origin = camera.project_ray_origin(mouse_pos)
	var ray_dir = camera.project_ray_normal(mouse_pos)
	
	# Intersect ray with ground plane at y = 0
	var ground_plane = Plane(Vector3.UP, 0.0)
	var hit_pos = ground_plane.intersects_ray(ray_origin, ray_dir)
	
	if hit_pos:
		var item_size: int = 1
		if current_mode == Mode.PLACE:
			var item_def = Catalog.get_item(active_type_id)
			item_size = item_def.get("size", 1)
		elif current_mode == Mode.SELECT and not selected_entry.is_empty():
			item_size = selected_entry.get("size", 1)
		
		var grid_pos = grid_manager.world_to_grid(hit_pos, item_size)
		hovered_cell = grid_pos
		is_pointer_on_grid = grid_manager.is_in_bounds(grid_pos.x, grid_pos.y, item_size)
		
		if _ghost_root and _ghost_root.visible:
			if is_pointer_on_grid:
				var world_target = grid_manager.grid_to_world(grid_pos.x, grid_pos.y, item_size)
				_ghost_root.position = world_target
				var is_valid = grid_manager.is_valid_position(grid_pos.x, grid_pos.y, item_size, active_type_id)
				_update_ghost_validity(is_valid)
			else:
				_update_ghost_validity(false)
	else:
		is_pointer_on_grid = false

func _unhandled_input(event: InputEvent) -> void:
	# Rotate action (R key)
	if event.is_action_pressed("ui_cancel") or (event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE):
		if not selected_entry.is_empty():
			cancel_selection()
		elif current_mode != Mode.SELECT:
			set_mode(Mode.SELECT)
		get_viewport().set_input_as_handled()
		return
	
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_R:
			rotate_active()
			get_viewport().set_input_as_handled()
			return
		elif event.keycode == KEY_DELETE or event.keycode == KEY_BACKSPACE:
			if not selected_entry.is_empty():
				demolish_selected()
				get_viewport().set_input_as_handled()
				return
	
	# Left Mouse Button / Tap interaction
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_process_click_or_tap(event.position)
	elif event is InputEventScreenTouch and event.pressed:
		_process_click_or_tap(event.position)

func _process_click_or_tap(screen_pos: Vector2) -> void:
	if not camera or not grid_manager:
		return
	var ray_origin = camera.project_ray_origin(screen_pos)
	var ray_dir = camera.project_ray_normal(screen_pos)
	var ground_plane = Plane(Vector3.UP, 0.0)
	var hit_pos = ground_plane.intersects_ray(ray_origin, ray_dir)
	if not hit_pos:
		return
	
	var item_size: int = 1
	if current_mode == Mode.PLACE:
		var item_def = Catalog.get_item(active_type_id)
		item_size = item_def.get("size", 1)
	elif current_mode == Mode.SELECT and not selected_entry.is_empty():
		item_size = selected_entry.get("size", 1)
	
	var grid_pos = grid_manager.world_to_grid(hit_pos, item_size)
	if grid_manager.is_in_bounds(grid_pos.x, grid_pos.y, item_size):
		_handle_grid_click(grid_pos.x, grid_pos.y)

func _handle_grid_click(gx: int, gz: int) -> void:
	match current_mode:
		Mode.EXPLORE:
			_handle_explore_click(gx, gz)
		Mode.SELECT:
			_handle_select_click(gx, gz)
		Mode.PLACE:
			_handle_place_click(gx, gz)
		Mode.DEMOLISH:
			_handle_demolish_click(gx, gz)

func _handle_explore_click(gx: int, gz: int) -> void:
	var top_item = grid_manager.get_top_item_at(gx, gz)
	if top_item.is_empty():
		return
	var node = top_item.get("node")
	if not node or not is_instance_valid(node):
		return
	
	var item_type = top_item.get("type", "")
	var creature_speech = {
		"cat": "Miau! 🐾",
		"dog": "Wuff! 🐶",
		"duck": "Quak! 🦆",
		"rabbit": "Schnupper! 🐰",
		"boy": "Hallo! 👋",
		"girl": "Juhu! ✨",
	}
	
	if creature_speech.has(item_type):
		creature_interacted.emit(item_type, creature_speech[item_type], node.global_position)
		if item_type == "cat":
			if node.has_method("interact"):
				node.interact()
			else:
				AudioManager.play("cat_meow")
				_animate_explore_bounce(node)
		elif item_type == "dog":
			AudioManager.play("dog_bark")
			_animate_explore_bounce(node)
		elif item_type == "duck":
			AudioManager.play("duck_quack")
			_animate_explore_bounce(node)
		else:
			AudioManager.play("ui_pop")
			_animate_explore_bounce(node)
		return
	
	if node.has_method("interact"):
		node.interact()
	elif node.has_method("toggle_light"):
		node.toggle_light()
	else:
		AudioManager.play("pop")
		_animate_explore_bounce(node)

func _animate_explore_bounce(node: Node3D) -> void:
	var tween = create_tween()
	tween.tween_property(node, "scale", Vector3(1.12, 0.9, 1.12), 0.08).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "scale", Vector3.ONE, 0.14).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)

func _handle_select_click(gx: int, gz: int) -> void:
	# 1. If an item is already selected/lifted
	if not selected_entry.is_empty():
		# Attempt to move it to the target cell
		if history_manager:
			history_manager.record_state_before_action()
		var success = grid_manager.move_item(selected_entry, gx, gz)
		if success:
			grid_manager.drop_item(selected_entry)
			selected_entry = {}
			selection_changed.emit(false, {})
		else:
			# If clicked on same position, just put it back down
			if selected_entry["gx"] == gx and selected_entry["gz"] == gz:
				grid_manager.drop_item(selected_entry)
				selected_entry = {}
				selection_changed.emit(false, {})
		return
	
	# 2. Pick up item under cursor
	var target_entry = grid_manager.get_top_item_at(gx, gz)
	if not target_entry.is_empty():
		selected_entry = target_entry
		_original_gx = target_entry["gx"]
		_original_gz = target_entry["gz"]
		var lift_h: float = 0.22 if target_entry.get("is_ground", false) else 0.35
		grid_manager.lift_item(target_entry, lift_h)
		selection_changed.emit(true, selected_entry)

func _handle_place_click(gx: int, gz: int) -> void:
	var item_def = Catalog.get_item(active_type_id)
	var size: int = item_def.get("size", 1)
	
	if grid_manager.is_valid_position(gx, gz, size, active_type_id):
		if history_manager:
			history_manager.record_state_before_action()
		var entry = grid_manager.place(active_type_id, gx, gz, active_rot_step)
		if not entry.is_empty():
			AudioManager.play("pop")
			item_placed.emit(entry)

func _handle_demolish_click(gx: int, gz: int) -> void:
	if history_manager:
		history_manager.record_state_before_action()
	var ok = grid_manager.demolish_at(gx, gz)
	if ok:
		AudioManager.play("demolish")

func cancel_selection() -> void:
	if selected_entry.is_empty():
		return
	# Restore to original coordinates if moved
	if selected_entry["gx"] != _original_gx or selected_entry["gz"] != _original_gz:
		grid_manager.move_item(selected_entry, _original_gx, _original_gz)
	grid_manager.drop_item(selected_entry)
	selected_entry = {}
	selection_changed.emit(false, {})

func demolish_selected() -> void:
	if selected_entry.is_empty():
		return
	if history_manager:
		history_manager.record_state_before_action()
	if selected_entry.get("is_ground", false):
		grid_manager.remove_ground_at(selected_entry["gx"], selected_entry["gz"])
	else:
		grid_manager.remove_object(selected_entry["id"])
	selected_entry = {}
	selection_changed.emit(false, {})
