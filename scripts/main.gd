class_name Main
extends Node3D

## Main scene controller orchestrating Camera, Day/Night, Island Base, and initial diorama objects.

@export var default_grid_size: int = 12

@onready var camera_controller: CameraController = $CameraController
@onready var island_base: IslandBase = $IslandBase
@onready var day_night: DayNightController = $DayNightController
@onready var grid_container: Node3D = $GridContainer

# Tracking placed items
var _placed_items: Dictionary = {}

func _ready() -> void:
	island_base.setup_grid(default_grid_size)
	spawn_starter_island_preview()

func grid_to_world(gx: int, gz: int, item_size: int = 1) -> Vector3:
	var half: float = (float(default_grid_size) * 1.0) * 0.5
	var offset: float = (float(item_size) * 1.0) * 0.5
	return Vector3(float(gx) - half + offset, 0.0, float(gz) - half + offset)

func spawn_item(type_id: String, gx: int, gz: int, rot_step: int = 0) -> Node3D:
	var node = Catalog.instantiate_item(type_id)
	if not node:
		return null
	
	var item_def = Catalog.get_item(type_id)
	var size = item_def.get("size", 1)
	var is_ground = item_def.get("is_ground", false)
	
	var world_pos = grid_to_world(gx, gz, size)
	node.position = world_pos
	node.rotation.y = float(rot_step) * (PI * 0.5)
	
	grid_container.add_child(node)
	var key = "%d_%d_%s" % [gx, gz, "ground" if is_ground else "obj"]
	_placed_items[key] = node
	return node

func spawn_starter_island_preview() -> void:
	# 1. Base Meadow around central structures
	for x in range(1, 9):
		for z in range(1, 9):
			spawn_item("grass", x, z)
	
	# 2. Cobblestone Path
	var path_coords = [
		Vector2i(5, 4), Vector2i(5, 5), Vector2i(5, 6), Vector2i(5, 7),
		Vector2i(6, 4), Vector2i(7, 4), Vector2i(4, 4), Vector2i(3, 4)
	]
	for p in path_coords:
		spawn_item("stone", p.x, p.y)
	
	# 3. Wood Deck near cottage
	spawn_item("wood", 2, 3)
	spawn_item("wood", 2, 4)
	spawn_item("wood", 2, 5)
	
	# 4. Cozy Water Pond Corner
	var water_coords = [
		Vector2i(10, 10), Vector2i(10, 11), Vector2i(11, 10), Vector2i(11, 11), Vector2i(9, 11)
	]
	for w in water_coords:
		spawn_item("water", w.x, w.y)
	
	# 5. Cozy Cottage (2x2)
	spawn_item("cottage", 3, 2, 0)
	
	# 6. Garden Bench & Cat
	spawn_item("bench", 7, 3, 0)
	var cat = spawn_item("cat", 7, 3, 0)
	if cat:
		cat.position.y = 0.28 # Snapped to bench seat
	
	# 7. Streetlamp
	spawn_item("streetlamp", 5, 3, 0)
	
	# 8. Trees & Flowerbed
	spawn_item("pine", 1, 1, 0)
	spawn_item("pine", 8, 1, 0)
	spawn_item("tree", 1, 7, 0)
	spawn_item("tree", 8, 8, 0)
	spawn_item("flowerbed", 7, 2, 0)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_T:
			day_night.toggle()
		elif event.keycode == KEY_SPACE:
			camera_controller.reset_view()
