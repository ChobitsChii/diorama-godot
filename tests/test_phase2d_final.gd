extends SceneTree

func _init() -> void:
	print("\n--- Starting Phase 2d Final Test Suite ---")
	
	# Test 1: AudioManager & Mute Toggle
	print("Test 1: AudioManager & Bus Mute...")
	var initial_muted = AudioManager.is_muted()
	var toggled = AudioManager.toggle_mute()
	assert(toggled == not initial_muted, "Toggle mute should flip mute state")
	AudioManager.toggle_mute() # restore
	assert(AudioManager.is_muted() == initial_muted, "Restoring mute should match initial state")
	for sound in AudioManager.SOUND_PATHS:
		var path = AudioManager.SOUND_PATHS[sound]
		assert(ResourceLoader.exists(path), "Audio file exists: %s" % path)
	print("  PASS: AudioManager & sound assets verified OK")
	
	# Test 2: Catalog items completeness & instantiation
	print("Test 2: Catalog items completeness...")
	var categories = ["ground", "buildings", "nature", "creatures", "deco"]
	var total_items = 0
	for cat in categories:
		var items = Catalog.get_items_by_category(cat)
		assert(items.size() > 0, "Category %s should have items" % cat)
		total_items += items.size()
		for item in items:
			var node = Catalog.instantiate_item(item["id"])
			assert(node != null, "Item %s instantiates successfully" % item["id"])
			node.free()
	assert(total_items >= 20, "Catalog should have at least 20 items (got %d)" % total_items)
	print("  PASS: All %d Catalog items instantiate cleanly OK" % total_items)
	
	# Test 3: CatProp stability
	print("Test 3: CatProp interaction stability...")
	var cat_scene = load("res://scenes/catalog/creatures/cat.tscn")
	var cat_instance = cat_scene.instantiate()
	cat_instance.position = Vector3(0, 0.5, 0)
	root.add_child(cat_instance)
	var initial_y = cat_instance.position.y
	cat_instance.interact()
	cat_instance.interact() # second click during jump shouldn't corrupt base_y
	assert(cat_instance._base_y == initial_y, "Cat base_y should remain stable")
	cat_instance.queue_free()
	print("  PASS: CatProp jump stability OK")
	
	# Test 4: Grid dynamic resizing
	print("Test 4: GridManager dynamic resizing...")
	var grid_mgr = GridManager.new()
	root.add_child(grid_mgr)
	grid_mgr.grid_size = 12
	grid_mgr.place("grass", 4, 4)
	grid_mgr.place("tree", 4, 4)
	
	var orig_world_pos = grid_mgr.grid_to_world(4, 4)
	grid_mgr.set_grid_size(16)
	var new_world_pos = grid_mgr.grid_to_world(4, 4)
	assert(grid_mgr.grid_size == 16, "Grid size updated to 16")
	assert(orig_world_pos != new_world_pos, "World position recalculated for new origin")
	grid_mgr.queue_free()
	print("  PASS: GridManager dynamic resizing OK")
	
	print("--- All Phase 2d Final Tests Passed Successfully! ---\n")
	quit(0)
