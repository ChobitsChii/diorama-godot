extends Node3D

## Root orchestrator for the Diorama Sandbox application.
## Wires together Camera, IslandBase, GridManager, PlacementController,
## HistoryManager, StorageManager, DayNightController, ParticleManager, AudioManager, and HUD.

@onready var camera_rig: CameraController = $CameraRig
@onready var day_night: DayNightController = $DayNightController
@onready var island_base: IslandBase = $IslandBase
@onready var grid_manager: GridManager = $GridManager
@onready var history_manager: HistoryManager = $HistoryManager
@onready var storage_manager: StorageManager = $StorageManager
@onready var placement_controller: PlacementController = $PlacementController
@onready var hud: Control = $UILayer/HUD

var audio_manager: AudioManager
var sync_manager: SyncManager
var particle_manager: ParticleManager

func _ready() -> void:
	SettingsManager.apply_saved_settings()
	
	audio_manager = AudioManager.new()
	audio_manager.name = "AudioManager"
	add_child(audio_manager)
	
	particle_manager = ParticleManager.new()
	particle_manager.name = "ParticleManager"
	add_child(particle_manager)
	
	sync_manager = SyncManager.new()
	sync_manager.name = "SyncManager"
	add_child(sync_manager)
	
	if day_night and grid_manager:
		day_night.mode_changed.connect(func(is_night: bool):
			grid_manager.apply_night_mode(is_night)
		)
	
	if hud and hud.has_method("setup"):
		hud.setup(self)
	
	# Load saved diorama or initialize default Modulon starter island
	if not storage_manager.load_local():
		spawn_starter_island()
		storage_manager.save_local()
	else:
		island_base.grid_size = grid_manager.grid_size
		camera_rig.reset_view_immediate(grid_manager.grid_size)
		if hud and hud.has_method("sync_grid_size"):
			hud.sync_grid_size(grid_manager.grid_size)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		var ke := event as InputEventKey
		if ke.keycode == KEY_F11 or (ke.keycode == KEY_ENTER and ke.alt_pressed):
			var new_mode := SettingsManager.toggle_fullscreen()
			if hud and hud.has_method("on_display_mode_changed"):
				hud.on_display_mode_changed(new_mode)
			get_viewport().set_input_as_handled()

## Builds the exact Modulon starter village scene from `storage.js` `loadDefaultStarterScene(grid)`.
func spawn_starter_island() -> void:
	grid_manager.clear(false)
	grid_manager.grid_size = 12
	island_base.grid_size = 12
	camera_rig.reset_view_immediate(12)
	
	# 1. Lush central grass patch (3..7 x 3..7)
	for x in range(3, 8):
		for z in range(3, 8):
			grid_manager.place("grass", x, z)
	
	# 2. Stone path from cottage to fountain & south plaza
	grid_manager.place("stone", 5, 5)
	grid_manager.place("stone", 5, 6)
	grid_manager.place("stone", 5, 7)
	grid_manager.place("stone", 5, 8)
	grid_manager.place("stone", 6, 8)
	grid_manager.place("stone", 7, 8)
	
	# 3. Grass around natural pond (7..9 x 2..4) + (9,5), (10,5)
	for x in range(7, 10):
		for z in range(2, 5):
			grid_manager.place("grass", x, z)
	grid_manager.place("grass", 9, 5)
	grid_manager.place("grass", 10, 5)
	
	# 4. Cozy Beer Garden area (7..10 x 6..8) with wood deck
	for x in range(7, 11):
		for z in range(6, 9):
			grid_manager.place("grass", x, z)
	grid_manager.place("wood", 8, 6)
	grid_manager.place("wood", 9, 6)
	grid_manager.place("wood", 8, 7)
	grid_manager.place("wood", 9, 7)
	
	# 5. Extra greenery patches (south & west)
	grid_manager.place("grass", 8, 9)
	grid_manager.place("grass", 9, 9)
	grid_manager.place("grass", 10, 9)
	grid_manager.place("grass", 2, 6)
	grid_manager.place("grass", 2, 7)
	
	# 6. Starter Buildings & Landmarks
	grid_manager.place("cottage", 3, 3, 0)
	grid_manager.place("fountain", 6, 6, 0)
	grid_manager.place("pond", 8, 3, 0)
	
	# 7. Ducks swimming in the pond
	grid_manager.place("duck", 8, 3, 0)
	grid_manager.place("duck", 9, 4, 1)
	
	# 8. Beer garden tables & sitting guests
	grid_manager.place("beertable", 8, 6, 0)
	grid_manager.place("beertable", 9, 6, 0)
	grid_manager.place("human", 8, 6, 0, "", {"gender": "male", "shirtColor": 0xef4444})
	grid_manager.place("human", 9, 6, 2, "", {"gender": "female", "shirtColor": 0xec4899})
	
	# 9. Wooden fences separating pond and beer garden
	grid_manager.place("fence", 7, 5, 0)
	grid_manager.place("fence", 8, 5, 0)
	grid_manager.place("fence", 9, 5, 0)
	
	# 10. Trees, Pines, Flowerpots & Cactus
	grid_manager.place("tree", 3, 6, 0)
	grid_manager.place("pine", 7, 2, 0)
	grid_manager.place("tree", 10, 4, 0)
	grid_manager.place("bush", 6, 4, 0)
	grid_manager.place("tree", 8, 9, 0)
	grid_manager.place("pine", 10, 8, 0)
	grid_manager.place("flowerpot", 3, 5, 0)
	grid_manager.place("flowerpot", 6, 3, 0)
	grid_manager.place("cactus", 2, 6, 0)
	
	# 11. Streetlamps, Bench & Village Creatures
	grid_manager.place("streetlamp", 4, 6, 0)
	grid_manager.place("streetlamp", 7, 7, 0)
	grid_manager.place("bench", 4, 7, 0)
	grid_manager.place("cat", 5, 7, 1)
	grid_manager.place("dog", 6, 5, 0)
	grid_manager.place("human", 5, 6, 0, "", {"gender": "female", "shirtColor": 0x8b5cf6})
	
	grid_manager.apply_night_mode(day_night.is_night if day_night else false)
	grid_manager.grid_changed.emit()
	if storage_manager:
		storage_manager.save_local()
	
	if hud and hud.has_method("sync_grid_size"):
		hud.sync_grid_size(12)

## Completely empties the island down to the bare pedestal (`🗑️ Komplett leeren`).
func clear_island_completely() -> void:
	grid_manager.clear(true)
	storage_manager.save_local()
