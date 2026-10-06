class_name Main
extends Node3D

## Main orchestrator scene linking Camera, Day/Night, IslandBase, GridManager, PlacementController, and HUD.

@export var default_grid_size: int = 12

@onready var camera_controller: CameraController = $CameraController
@onready var island_base: IslandBase = $IslandBase
@onready var day_night: DayNightController = $DayNightController
@onready var grid_manager: GridManager = $GridManager
@onready var placement_controller: PlacementController = $PlacementController
@onready var hud: HUD = $CanvasLayer/HUD

func _ready() -> void:
	# 1. Setup Island Base and Grid dimensions
	grid_manager.grid_size = default_grid_size
	island_base.setup_grid(default_grid_size)
	
	# 2. Wire Placement Controller dependencies
	placement_controller.grid_manager = grid_manager
	placement_controller.camera = camera_controller.camera
	
	# 3. Wire HUD
	hud.setup_controllers(placement_controller, day_night, camera_controller)
	
	# 4. Populate default starter diorama island
	spawn_starter_island()

func spawn_starter_island() -> void:
	grid_manager.clear()
	
	# 1. Base Meadow around central structures (gx: 1..8, gz: 1..8)
	for x in range(1, 9):
		for z in range(1, 9):
			grid_manager.place("grass", x, z)
	
	# 2. Cobblestone Path
	var path_coords = [
		Vector2i(5, 4), Vector2i(5, 5), Vector2i(5, 6), Vector2i(5, 7),
		Vector2i(6, 4), Vector2i(7, 4), Vector2i(4, 4), Vector2i(3, 4)
	]
	for p in path_coords:
		grid_manager.place("stone", p.x, p.y)
	
	# 3. Wood Deck near cottage
	grid_manager.place("wood", 2, 3)
	grid_manager.place("wood", 2, 4)
	grid_manager.place("wood", 2, 5)
	
	# 4. Cozy Water Pond Corner
	var water_coords = [
		Vector2i(10, 10), Vector2i(10, 11), Vector2i(11, 10), Vector2i(11, 11), Vector2i(9, 11)
	]
	for w in water_coords:
		grid_manager.place("water", w.x, w.y)
	
	# 5. Cozy Cottage (2x2) at gx: 3, gz: 2
	grid_manager.place("cottage", 3, 2, 0)
	
	# 6. Garden Bench at gx: 7, gz: 3
	grid_manager.place("bench", 7, 3, 0)
	
	# 7. Cute cat sitting on the bench!
	grid_manager.place("cat", 7, 3, 0)
	
	# 8. Nostalgic Streetlamp along the path at gx: 5, gz: 3
	grid_manager.place("streetlamp", 5, 3, 0)
	
	# 9. Pine trees, leafy trees, and flowerbed
	grid_manager.place("pine", 1, 1, 0)
	grid_manager.place("pine", 8, 1, 0)
	grid_manager.place("tree", 1, 7, 0)
	grid_manager.place("tree", 8, 8, 0)
	grid_manager.place("flowerbed", 7, 2, 0)
