class_name PlacementController
extends Node3D

## Handles 3D raycasting, ghost preview, object selection/repositioning,
## interactive Explore mode (harvesting, feeding from the Harvest Basket, creature reactions),
## and demolish dust puffs.

enum Tool {
	SELECT,
	EXPLORE,
	PLACE,
	DEMOLISH,
}

signal tool_changed(new_tool: int)
signal selection_changed(selected_entry: Dictionary)
signal object_interacted(entry: Dictionary, message: String)
signal item_harvested(food_key: String, world_pos: Vector3)
signal creature_fed(entry: Dictionary, food_key: String, world_pos: Vector3)
signal placement_hint(message: String)

@export var grid_manager: GridManager
@export var camera: Camera3D
@export var history_manager: HistoryManager

var current_tool: int = Tool.PLACE
var active_type_id: String = "grass"
var current_rotation_step: int = 0 # 0..3 (multiples of 90 deg)
var selected_entry: Dictionary = {}
var selected_food: String = "" # "strawberry", "potato", "mushroom", "nut", or ""

var _ghost_root: Node3D
var _ghost_mesh_holder: Node3D
var _ghost_cursor_box: MeshInstance3D
var _selection_ring: MeshInstance3D
var _hover_cell: Vector2i = Vector2i(-1, -1)
var _is_dragging_paint: bool = false
var _pointer_down_pos: Vector2 = Vector2.ZERO
var _pointer_moved: bool = false

var _mat_valid: StandardMaterial3D
var _mat_invalid: StandardMaterial3D
var _mat_select: StandardMaterial3D

const CREATURE_TYPES: Array[String] = [
	"human", "cat", "dog", "duck", "squirrel", "axolotl",
	"pig", "parrot", "horse", "elephant", "lion", "whitetiger"
]

func _ready() -> void:
	_setup_materials()
	_setup_ghost_and_selection()
	set_active_item(active_type_id)

func _setup_materials() -> void:
	_mat_valid = StandardMaterial3D.new()
	_mat_valid.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_mat_valid.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_mat_valid.albedo_color = Color(0.22, 0.74, 0.97, 0.42)
	
	_mat_invalid = StandardMaterial3D.new()
	_mat_invalid.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_mat_invalid.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_mat_invalid.albedo_color = Color(0.94, 0.27, 0.27, 0.48)
	
	_mat_select = StandardMaterial3D.new()
	_mat_select.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_mat_select.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_mat_select.albedo_color = Color(0.98, 0.80, 0.08, 0.55)

func _setup_ghost_and_selection() -> void:
	_ghost_root = Node3D.new()
	_ghost_root.name = "GhostRoot"
	add_child(_ghost_root)
	
	_ghost_mesh_holder = Node3D.new()
	_ghost_root.add_child(_ghost_mesh_holder)
	
	_ghost_cursor_box = MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(1.02, 0.05, 1.02)
	_ghost_cursor_box.mesh = box
	_ghost_cursor_box.position = Vector3(0.0, 0.025, 0.0)
	_ghost_cursor_box.material_override = _mat_valid
	_ghost_root.add_child(_ghost_cursor_box)
	
	_selection_ring = MeshInstance3D.new()
	var sbox := BoxMesh.new()
	sbox.size = Vector3(1.06, 0.06, 1.06)
	_selection_ring.mesh = sbox
	_selection_ring.position = Vector3(0.0, 0.03, 0.0)
	_selection_ring.material_override = _mat_select
	_selection_ring.visible = false
	add_child(_selection_ring)

func set_tool(new_tool: int) -> void:
	if current_tool == new_tool:
		return
	if current_tool == Tool.SELECT and not selected_entry.is_empty():
		clear_selection()
	current_tool = new_tool
	_rebuild_ghost_preview()
	_update_ghost_visibility()
	tool_changed.emit(current_tool)

func set_active_item(type_id: String) -> void:
	active_type_id = Catalog.normalize_type(type_id)
	_rebuild_ghost_preview()
	_update_ghost_visibility()

func rotate_step() -> void:
	current_rotation_step = (current_rotation_step + 1) % 4
	AudioManager.play("click")
	if current_tool == Tool.SELECT and not selected_entry.is_empty():
		_rotate_selected_object()
	else:
		_update_ghost_transform()

func delete_selected() -> void:
	if not selected_entry.is_empty() and grid_manager:
		if history_manager:
			history_manager.record_State()
		var wpos: Vector3 = grid_manager.grid_to_world(selected_entry["gx"], selected_entry["gz"], Vector2i(selected_entry.get("size", 1), selected_entry.get("size", 1)))
		grid_manager.remove_by_id(selected_entry["id"])
		_spawn_demolish_effect(wpos)
		AudioManager.play("demolish")
		clear_selection()

func clear_selection() -> void:
	selected_entry = {}
	if _selection_ring:
		_selection_ring.visible = false
	_rebuild_ghost_preview()
	_update_ghost_visibility()
	selection_changed.emit(selected_entry)

func _rebuild_ghost_preview() -> void:
	if not _ghost_mesh_holder:
		return
	for child in _ghost_mesh_holder.get_children():
		child.queue_free()
	
	var preview_type := ""
	if current_tool == Tool.PLACE:
		preview_type = active_type_id
	elif current_tool == Tool.SELECT and not selected_entry.is_empty():
		preview_type = selected_entry.get("type", "")
	
	if not preview_type.is_empty():
		var preview_node := Catalog.instantiate_item(preview_type)
		if preview_node:
			preview_node.set_process(false)
			_disable_colliders_recursive(preview_node)
			_ghost_mesh_holder.add_child(preview_node)
		var item_def := Catalog.get_item(preview_type)
		var fp: Vector2i = item_def.get("size", Vector2i(1, 1))
		var box := _ghost_cursor_box.mesh as BoxMesh
		if box:
			box.size = Vector3(float(fp.x) + 0.02, 0.05, float(fp.y) + 0.02)
	else:
		var box := _ghost_cursor_box.mesh as BoxMesh
		if box:
			box.size = Vector3(1.02, 0.05, 1.02)

func _disable_colliders_recursive(node: Node) -> void:
	if node is CollisionObject3D:
		(node as CollisionObject3D).collision_layer = 0
		(node as CollisionObject3D).collision_mask = 0
	for child in node.get_children():
		_disable_colliders_recursive(child)

func _update_ghost_visibility() -> void:
	if not _ghost_root:
		return
	if current_tool == Tool.EXPLORE:
		_ghost_root.visible = false
		return
	if _hover_cell.x < 0 or _hover_cell.y < 0:
		_ghost_root.visible = false
		return
	_ghost_root.visible = true
	_ghost_mesh_holder.visible = (current_tool == Tool.PLACE) or (current_tool == Tool.SELECT and not selected_entry.is_empty())

func _unhandled_input(event: InputEvent) -> void:
	if not grid_manager or not camera:
		return
	
	if event is InputEventKey and event.pressed and not event.echo:
		var ke := event as InputEventKey
		if ke.keycode == KEY_R:
			rotate_step()
			get_viewport().set_input_as_handled()
			return
		elif ke.keycode == KEY_DELETE or ke.keycode == KEY_BACKSPACE:
			if current_tool == Tool.SELECT and not selected_entry.is_empty():
				delete_selected()
				get_viewport().set_input_as_handled()
				return
		elif ke.keycode == KEY_ESCAPE:
			if not selected_food.is_empty():
				selected_food = ""
				placement_hint.emit("")
				get_viewport().set_input_as_handled()
				return
			if not selected_entry.is_empty():
				clear_selection()
				get_viewport().set_input_as_handled()
				return
	
	if event is InputEventMouseMotion:
		var mm := event as InputEventMouseMotion
		if _pointer_down_pos != Vector2.ZERO and mm.position.distance_to(_pointer_down_pos) > 6.0:
			_pointer_moved = true
		_update_hover_from_screen(mm.position)
		if _is_dragging_paint and current_tool == Tool.PLACE:
			var item_def := Catalog.get_item(active_type_id)
			if item_def.get("is_ground", false):
				_execute_place_at_hover(false)
	
	elif event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT:
			if mb.pressed:
				_pointer_down_pos = mb.position
				_pointer_moved = false
				_update_hover_from_screen(mb.position)
				if current_tool == Tool.PLACE:
					var item_def := Catalog.get_item(active_type_id)
					if item_def.get("is_ground", false):
						if history_manager:
							history_manager.record_State()
						_is_dragging_paint = true
						_execute_place_at_hover(false)
					else:
						_execute_place_at_hover(true)
				elif current_tool == Tool.DEMOLISH:
					_execute_demolish_at_hover()
				elif current_tool == Tool.SELECT:
					_execute_select_at_hover()
			else:
				_is_dragging_paint = false
				if current_tool == Tool.EXPLORE and not _pointer_moved:
					_update_hover_from_screen(mb.position)
					_execute_explore_at_hover(mb.position)
				_pointer_down_pos = Vector2.ZERO

	elif event is InputEventScreenTouch:
		var st := event as InputEventScreenTouch
		if st.index == 0:
			if st.pressed:
				_pointer_down_pos = st.position
				_pointer_moved = false
				_update_hover_from_screen(st.position)
			else:
				if not _pointer_moved:
					_update_hover_from_screen(st.position)
					match current_tool:
						Tool.PLACE: _execute_place_at_hover(true)
						Tool.DEMOLISH: _execute_demolish_at_hover()
						Tool.SELECT: _execute_select_at_hover()
						Tool.EXPLORE: _execute_explore_at_hover(st.position)
				_pointer_down_pos = Vector2.ZERO

func _update_hover_from_screen(screen_pos: Vector2) -> void:
	var ray_origin := camera.project_ray_origin(screen_pos)
	var ray_dir := camera.project_ray_normal(screen_pos)
	if absf(ray_dir.y) < 0.0001:
		return
	var t := -ray_origin.y / ray_dir.y
	if t < 0.0:
		_hover_cell = Vector2i(-1, -1)
		_update_ghost_visibility()
		return
	
	var hit_pos := ray_origin + ray_dir * t
	var cell := grid_manager.world_to_grid(hit_pos)
	if not grid_manager.is_within_bounds(cell.x, cell.y):
		_hover_cell = Vector2i(-1, -1)
		_update_ghost_visibility()
		return
	
	_hover_cell = cell
	_update_ghost_transform()
	_update_ghost_visibility()

func _update_ghost_transform() -> void:
	if _hover_cell.x < 0 or _hover_cell.y < 0 or not grid_manager:
		return
	
	var preview_type := active_type_id
	if current_tool == Tool.SELECT and not selected_entry.is_empty():
		preview_type = selected_entry.get("type", "")
	
	var item_def := Catalog.get_item(preview_type)
	var fp: Vector2i = item_def.get("size", Vector2i(1, 1)) if current_tool in [Tool.PLACE, Tool.SELECT] and not item_def.is_empty() else Vector2i(1, 1)
	
	var world_pos := grid_manager.grid_to_world(_hover_cell.x, _hover_cell.y, fp)
	_ghost_root.global_position = world_pos
	_ghost_mesh_holder.rotation = Vector3(0.0, float(current_rotation_step) * (PI * 0.5), 0.0)
	
	var is_valid := true
	if current_tool == Tool.PLACE:
		is_valid = grid_manager.can_place(active_type_id, _hover_cell.x, _hover_cell.y) and _check_field_compatibility(active_type_id, _hover_cell.x, _hover_cell.y, false)
	elif current_tool == Tool.SELECT and not selected_entry.is_empty():
		is_valid = grid_manager.can_place( preview_type, _hover_cell.x, _hover_cell.y, selected_entry.get("id", ""))
	elif current_tool == Tool.DEMOLISH:
		is_valid = false
	
	_ghost_cursor_box.material_override = _mat_valid if is_valid else _mat_invalid

func _check_field_compatibility(type_id: String, gx: int, gz: int, emit_toast: bool = true) -> bool:
	var norm := Catalog.normalize_type(type_id)
	var ground := grid_manager.get_ground_at(gx, gz)
	var g_type: String = ground.get("type", "")
	if norm == "potato_plant":
		if g_type != "field_vegetable" and g_type != "grass":
			if emit_toast:
				placement_hint.emit("🥔 Kartoffelpflanzen wachsen auf dem Gemüseacker oder Gras!")
			return false
	elif norm == "strawberry_plant":
		if g_type != "field_fruit" and g_type != "grass":
			if emit_toast:
				placement_hint.emit("🍓 Erdbeerpflanzen wachsen auf dem Obstbeet oder Gras!")
			return false
	elif norm in ["mushrooms", "flyagaric"]:
		if g_type == "water":
			if emit_toast:
				placement_hint.emit("🍄 Pilze wachsen auf Waldboden oder Gras, nicht im Wasser!")
			return false
	return true

func _execute_place_at_hover(record_undo: bool = true) -> void:
	if _hover_cell.x < 0 or _hover_cell.y < 0:
		return
	if not _check_field_compatibility(active_type_id, _hover_cell.x, _hover_cell.y, true):
		return
	if not grid_manager.can_place(active_type_id, _hover_cell.x, _hover_cell.y):
		return
	
	if record_undo and history_manager:
		history_manager.record_State()
	
	var placed := grid_manager.place(active_type_id, _hover_cell.x, _hover_cell.y, current_rotation_step)
	if not placed.is_empty():
		var g := grid_manager.get_ground_at(_hover_cell.x, _hover_cell.y)
		var wpos := grid_manager.grid_to_world(_hover_cell.x, _hover_cell.y)
		if placed.get("type") == "water" or placed.get("type") == "pond" or g.get("type") == "water":
			AudioManager.play("water_splash")
			_spawn_splash_effect(wpos, false)
		else:
			AudioManager.play("ui_pop")

func _execute_demolish_at_hover() -> void:
	if _hover_cell.x < 0 or _hover_cell.y < 0:
		return
	var objs := grid_manager.get_objects_at(_hover_cell.x, _hover_cell.y)
	var ground := grid_manager.get_ground_at(_hover_cell.x, _hover_cell.y)
	if objs.is_empty() and ground.is_empty():
		return
	if history_manager:
		history_manager.record_State()
	var wpos := grid_manager.grid_to_world(_hover_cell.x, _hover_cell.y)
	var removed := grid_manager.remove_at(_hover_cell.x, _hover_cell.y)
	if not removed.is_empty():
		_spawn_demolish_effect(wpos)
		AudioManager.play("demolish")

func _execute_select_at_hover() -> void:
	if _hover_cell.x < 0 or _hover_cell.y < 0:
		return
	if selected_entry.is_empty():
		var obj := grid_manager.get_primary_object_at(_hover_cell.x, _hover_cell.y)
		if not obj.is_empty():
			selected_entry = obj
			current_rotation_step = int(round(float(obj.get("rotation", 0.0)) / (PI * 0.5))) % 4
			_update_selection_ring()
			_rebuild_ghost_preview()
			_update_ghost_transform()
			AudioManager.play("click")
			selection_changed.emit(selected_entry)
	else:
		var type_id: String = selected_entry["type"]
		var old_id: String = selected_entry["id"]
		if grid_manager.can_place(type_id, _hover_cell.x, _hover_cell.y, old_id):
			if history_manager:
				history_manager.record_State()
			grid_manager.remove_by_id(old_id)
			grid_manager.place(type_id, _hover_cell.x, _hover_cell.y, current_rotation_step, old_id)
			AudioManager.play("ui_pop")
			clear_selection()

func _rotate_selected_object() -> void:
	if selected_entry.is_empty() or not grid_manager:
		return
	if history_manager:
		history_manager.record_State()
	var obj_id: String = selected_entry["id"]
	var type_id: String = selected_entry["type"]
	var gx: int = selected_entry["gx"]
	var gz: int = selected_entry["gz"]
	grid_manager.remove_by_id(obj_id)
	var updated := grid_manager.place(type_id, gx, gz, current_rotation_step, obj_id)
	selected_entry = updated
	_update_selection_ring()
	selection_changed.emit(selected_entry)

func _update_selection_ring() -> void:
	if selected_entry.is_empty() or not _selection_ring:
		if _selection_ring:
			_selection_ring.visible = false
		return
	var sz: int = selected_entry.get("size", 1)
	var sbox := _selection_ring.mesh as BoxMesh
	if sbox:
		sbox.size = Vector3(float(sz) + 0.08, 0.06, float(sz) + 0.08)
	_selection_ring.global_position = grid_manager.grid_to_world(selected_entry["gx"], selected_entry["gz"], Vector2i(sz, sz)) + Vector3(0.0, 0.03, 0.0)
	_selection_ring.visible = true

func _execute_explore_at_hover(screen_pos: Vector2 = Vector2.ZERO) -> void:
	var obj: Dictionary = {}
	# First try direct 3D physics raycast against PropColliders so tall objects (trees, cottages, perched animals) are easy to click!
	if screen_pos != Vector2.ZERO and camera:
		var space_state := get_world_3d().direct_space_state
		var from := camera.project_ray_origin(screen_pos)
		var to := from + camera.project_ray_normal(screen_pos) * 100.0
		var query := PhysicsRayQueryParameters3D.create(from, to)
		var hit := space_state.intersect_ray(query)
		if not hit.is_empty() and hit.has("collider"):
			var col: Node = hit["collider"]
			if col and col.get_parent() is DioramaProp:
				var dp := col.get_parent() as DioramaProp
				for entry in grid_manager.objects.values():
					if entry.get("node") == dp:
						obj = entry
						break
	
	if obj.is_empty():
		if _hover_cell.x < 0 or _hover_cell.y < 0:
			return
		obj = grid_manager.get_primary_object_at(_hover_cell.x, _hover_cell.y)
	
	if obj.is_empty():
		# Check if clicking on water tile
		if _hover_cell.x >= 0 and _hover_cell.y >= 0:
			var g := grid_manager.get_ground_at(_hover_cell.x, _hover_cell.y)
			if g.get("type") == "water":
				var wpos := grid_manager.grid_to_world(_hover_cell.x, _hover_cell.y)
				AudioManager.play("water_splash")
				_spawn_splash_effect(wpos, false)
		return
	
	var node: Node3D = obj.get("node")
	var type_id: String = obj.get("type", "")
	var wpos := node.global_position if is_instance_valid(node) else grid_manager.grid_to_world(obj["gx"], obj["gz"])
	
	# 1. Check if feeding a creature from the Harvest Basket!
	if not selected_food.is_empty() and (type_id in CREATURE_TYPES):
		if is_instance_valid(node) and node is DioramaProp:
			var dp := node as DioramaProp
			match type_id:
				"human": dp.trigger_action("wave", 0.9)
				"dog": dp.trigger_action("bark", 0.7)
				"pig": dp.trigger_action("oink", 0.7)
				"parrot": dp.trigger_action("flap", 0.8)
				"horse": dp.trigger_action("rear", 0.8)
				"elephant": dp.trigger_action("trumpet", 0.8)
				"lion": dp.trigger_action("roar", 0.8)
				"whitetiger": dp.trigger_action("pounce", 0.7)
				"squirrel": dp.trigger_action("chatter", 0.7)
				"axolotl": dp.trigger_action("wiggle", 0.7)
		AudioManager.play("eat_crunch")
		_spawn_hearts_effect(wpos, 5)
		creature_fed.emit(obj, selected_food, wpos)
		return
	
	# 2. Check if harvesting a ripe plant (strawberry_plant, potato_plant, mushrooms)
	if is_instance_valid(node) and node is DioramaProp:
		var dp := node as DioramaProp
		if not dp.harvest_yield.is_empty():
			if dp.can_harvest():
				var yielded := dp.harvest()
				AudioManager.play("harvest")
				_spawn_leaves_effect(wpos, 5)
				item_harvested.emit(yielded, wpos)
			else:
				AudioManager.play("leaf_rustle")
				object_interacted.emit(obj, "🌱 Wächst noch nach... Bitte kurz warten!")
			return
	
	# 3. Standard interactive explore behavior per object type
	var msg := ""
	var dp := node as DioramaProp if (is_instance_valid(node) and node is DioramaProp) else null
	match type_id:
		"cat":
			if dp: dp.trigger_action("sleep_toggle", 0.5)
			AudioManager.play("cat_meow")
			_spawn_hearts_effect(wpos, 3)
			msg = "💤 Schnurr..." if (dp and dp.is_sleeping) else "🐱 Miau!"
		"dog":
			if dp: dp.trigger_action("bark", 0.75)
			AudioManager.play("dog_bark")
			_spawn_hearts_effect(wpos, 3)
			msg = "🐶 Wuff! Wuff!"
		"duck":
			AudioManager.play("duck_quack")
			_spawn_splash_effect(wpos, false)
			msg = "🦆 Quak! Quak!"
		"squirrel":
			if dp: dp.trigger_action("chatter", 0.75)
			AudioManager.play("squirrel_chirp")
			_spawn_hearts_effect(wpos, 3)
			msg = "🐿️ Knusper-Fiep!"
		"axolotl":
			if dp: dp.trigger_action("wiggle", 0.75)
			AudioManager.play("axolotl_bubble")
			_spawn_splash_effect(wpos, false)
			msg = "🦎 Blubb! ♥"
		"pig":
			if dp: dp.trigger_action("oink", 0.75)
			AudioManager.play("pig_oink")
			_spawn_hearts_effect(wpos, 3)
			msg = "🐷 Oink! Oink!"
		"parrot":
			if dp: dp.trigger_action("flap", 0.85)
			AudioManager.play("parrot_squawk")
			msg = "🦜 Kraaah! Hallo!"
		"horse":
			if dp: dp.trigger_action("rear", 0.85)
			AudioManager.play("horse_whinny")
			_spawn_hearts_effect(wpos, 3)
			msg = "🐴 Wieher!"
		"elephant":
			if dp: dp.trigger_action("trumpet", 0.85)
			AudioManager.play("elephant_trumpet")
			msg = "🐘 Törööö!"
		"lion":
			if dp: dp.trigger_action("roar", 0.85)
			AudioManager.play("lion_roar")
			msg = "🦁 Rooaaar!"
		"whitetiger":
			if dp: dp.trigger_action("pounce", 0.75)
			AudioManager.play("tiger_purr")
			_spawn_hearts_effect(wpos, 3)
			msg = "🐯 Chuff! Schnurr!"
		"human":
			if dp: dp.trigger_action("wave", 0.9)
			AudioManager.play("ui_pop")
			_spawn_hearts_effect(wpos, 3)
			msg = "👋 Hallo! Was für ein schöner Tag!"
		"streetlamp":
			if dp:
				var m := dp.cycle_lamp_mode()
				AudioManager.play("switch")
				msg = "💡 Laterne: %s" % ("Immer AN" if m == "on" else ("Immer AUS" if m == "off" else "Automatik"))
		"cottage":
			if dp: dp.trigger_action("shake", 0.35)
			AudioManager.play("click_wood")
			msg = "🏡 Klopf, klopf! Gemütliches Landhaus."
		"townhouse", "apartment":
			if dp: dp.trigger_action("shake", 0.35)
			AudioManager.play("doorbell")
			msg = "🔔 Ding-Dong!"
		"fountain":
			AudioManager.play("water_splash")
			_spawn_splash_effect(wpos, true)
			msg = "⛲ Plätscher!"
		"pond":
			AudioManager.play("water_splash")
			_spawn_splash_effect(wpos, false)
			msg = "🏞️ Platsch!"
		"tree", "pine":
			if dp: dp.trigger_action("shake", 0.45)
			AudioManager.play("leaf_rustle")
			_spawn_leaves_effect(wpos, 8)
			# 65% chance to shake a nut into the Harvest Basket!
			if randf() < 0.65:
				AudioManager.play("harvest")
				item_harvested.emit("nut", wpos)
				return
			else:
				msg = "🌳 Raschel... (Noch mal schütteln für Nüsse!)"
		"bush", "flowerpot", "claypot", "sunflower", "cactus", "flyagaric":
			if dp: dp.trigger_action("shake", 0.4)
			AudioManager.play("leaf_rustle")
			_spawn_leaves_effect(wpos, 4)
			msg = "🌿 Raschel..."
		_:
			if dp: dp.trigger_action("shake", 0.35)
			AudioManager.play("click_wood")
	
	if not msg.is_empty():
		object_interacted.emit(obj, msg)

func _get_particle_manager() -> ParticleManager:
	return get_tree().root.find_child("ParticleManager", true, false) as ParticleManager

func _spawn_hearts_effect(pos: Vector3, count: int = 4) -> void:
	var pm := _get_particle_manager()
	if pm:
		pm.spawn_hearts(pos, count)

func _spawn_leaves_effect(pos: Vector3, count: int = 7) -> void:
	var pm := _get_particle_manager()
	if pm:
		pm.spawn_leaves(pos, count)

func _spawn_splash_effect(pos: Vector3, big: bool = false) -> void:
	var pm := _get_particle_manager()
	if pm:
		pm.spawn_splash(pos, big)

func _spawn_demolish_effect(pos: Vector3) -> void:
	var pm := _get_particle_manager()
	if pm:
		pm.spawn_demolish_puff(pos)
