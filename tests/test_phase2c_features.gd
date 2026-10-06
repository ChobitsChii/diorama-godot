extends SceneTree

## Automated Headless Test Suite for Phase 2b Bugfixes and Phase 2c Features

func _init() -> void:
	print("--- Starting Phase 2b Bugfixes & Phase 2c Test Suite ---")
	
	var grid = GridManager.new()
	grid.grid_size = 12
	grid.cell_size = 1.0
	root.add_child(grid)
	
	# -------------------------------------------------------------------------
	# 1. Bugfix Test: Water Tile Placement (tile_water / water)
	# -------------------------------------------------------------------------
	print("Test 1: Water tile placement & normalization...")
	var water_entry = grid.place("water", 4, 4)
	assert(not water_entry.is_empty(), "Failed to place water tile with id 'water'")
	assert(water_entry["is_ground"] == true, "Water tile must be is_ground=true")
	assert(grid.ground_tiles.has(Vector2i(4, 4)), "Water tile must be in ground_tiles dict")
	
	# Test alias 'tile_water'
	var water_alias_entry = grid.place("tile_water", 4, 5)
	assert(not water_alias_entry.is_empty(), "Failed to place water tile with alias 'tile_water'")
	assert(water_alias_entry["is_ground"] == true, "Alias tile_water must be is_ground=true")
	print("  PASS: Water tile placement OK")
	
	# -------------------------------------------------------------------------
	# 2. DioramaSerializer Serialization & Deserialization
	# -------------------------------------------------------------------------
	print("Test 2: DioramaSerializer JSON Import & Export...")
	grid.clear()
	grid.place("grass", 1, 1)
	grid.place("water", 2, 2)
	grid.place("cottage", 3, 3, 1) # 90 degrees
	grid.place("cat", 5, 5, 2)     # 180 degrees
	
	var json_str = DioramaSerializer.serialize_to_json(grid, false)
	assert(json_str.contains("\"gridSize\":12"), "JSON missing gridSize")
	assert(json_str.contains("\"type\":\"water\""), "JSON missing water ground tile")
	assert(json_str.contains("\"type\":\"cottage\""), "JSON missing cottage object")
	
	# Clear grid and rehydrate from JSON
	var rehydrate_grid = GridManager.new()
	rehydrate_grid.grid_size = 12
	root.add_child(rehydrate_grid)
	
	var ok = DioramaSerializer.deserialize_from_json(json_str, rehydrate_grid)
	assert(ok == true, "Failed to deserialize JSON into grid")
	assert(rehydrate_grid.ground_tiles.has(Vector2i(1, 1)), "Missing grass tile after rehydration")
	assert(rehydrate_grid.ground_tiles.has(Vector2i(2, 2)), "Missing water tile after rehydration")
	assert(rehydrate_grid.cells.has(Vector2i(3, 3)), "Missing cottage occupancy after rehydration")
	
	var roundtrip_json = DioramaSerializer.serialize_to_json(rehydrate_grid, false)
	assert(roundtrip_json == json_str, "Roundtrip JSON mismatch!")
	print("  PASS: DioramaSerializer JSON Import/Export OK")
	
	# -------------------------------------------------------------------------
	# 3. StorageManager: user:// Persistence
	# -------------------------------------------------------------------------
	print("Test 3: StorageManager user:// Persistence...")
	var storage = StorageManager.new()
	storage.grid_manager = rehydrate_grid
	root.add_child(storage)
	
	var save_ok = storage.save_local()
	assert(save_ok == true, "Failed to save to user://diorama_save.json")
	assert(storage.has_save_file() == true, "Save file does not exist after saving")
	
	rehydrate_grid.clear()
	assert(rehydrate_grid.ground_tiles.size() == 0, "Grid should be empty before load")
	
	var load_ok = storage.load_local()
	assert(load_ok == true, "Failed to load from user://diorama_save.json")
	assert(rehydrate_grid.ground_tiles.has(Vector2i(1, 1)), "Ground tile not restored after load")
	assert(rehydrate_grid.cells.has(Vector2i(3, 3)), "Cottage not restored after load")
	print("  PASS: StorageManager user:// Persistence OK")
	
	# -------------------------------------------------------------------------
	# 4. HistoryManager: Multi-level Undo & Redo
	# -------------------------------------------------------------------------
	print("Test 4: HistoryManager Undo / Redo...")
	var history = HistoryManager.new()
	history.grid_manager = rehydrate_grid
	root.add_child(history)
	
	# Initial state: cottage at (3,3)
	assert(history.can_undo() == false, "Should not be able to undo initially")
	
	# Action 1: Place a tree
	history.record_state_before_action()
	rehydrate_grid.place("pine", 8, 8)
	assert(history.can_undo() == true, "Should be able to undo after recording state")
	assert(rehydrate_grid.cells.has(Vector2i(8, 8)), "Pine tree should be placed")
	
	# Action 2: Undo placing the tree
	var undo_ok = history.undo()
	assert(undo_ok == true, "Undo failed")
	assert(not rehydrate_grid.cells.has(Vector2i(8, 8)), "Pine tree should be removed after undo")
	assert(history.can_redo() == true, "Should be able to redo after undo")
	
	# Action 3: Redo placing the tree
	var redo_ok = history.redo()
	assert(redo_ok == true, "Redo failed")
	assert(rehydrate_grid.cells.has(Vector2i(8, 8)), "Pine tree should be restored after redo")
	print("  PASS: HistoryManager Undo/Redo OK")
	
	# -------------------------------------------------------------------------
	# 5. SyncManager: Web API Payload Validation
	# -------------------------------------------------------------------------
	print("Test 5: SyncManager Web API client setup...")
	var sync_mgr = SyncManager.new()
	sync_mgr.server_url = "http://127.0.0.1:8000"
	root.add_child(sync_mgr)
	assert(sync_mgr._http_save != null, "SyncManager missing HttpSave node")
	assert(sync_mgr._http_load != null, "SyncManager missing HttpLoad node")
	print("  PASS: SyncManager OK")
	
	print("--- All Phase 2b Bugfixes & Phase 2c Tests Passed Successfully! ---")
	quit(0)
