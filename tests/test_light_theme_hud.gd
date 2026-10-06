extends SceneTree

func _init() -> void:
	call_deferred("_run_suite")

func _run_suite() -> void:
	print("\n--- Starting Light Theme HUD & Complete System Test ---")
	
	# Test 1: Catalog items count & category coverage
	print("Test 1: Catalog Items Coverage...")
	var categories = ["ground", "buildings", "nature", "creatures", "deco"]
	var total_items = 0
	for cat in categories:
		var items = Catalog.get_items_by_category(cat)
		assert(items.size() > 0, "Category %s has items" % cat)
		total_items += items.size()
	print("  PASS: Total Catalog items: %d across 5 categories" % total_items)
	assert(total_items >= 30, "Catalog should have at least 30 items")
	
	# Test 2: IslandBase 3D grid lines toggle
	print("Test 2: IslandBase 3D GridLines Toggle...")
	var island = IslandBase.new()
	root.add_child(island)
	island.setup_grid(12)
	assert(island.is_grid_lines_visible() == true, "Grid lines should default to visible")
	var toggled_off = island.toggle_grid_lines()
	assert(toggled_off == false, "Grid lines should toggle to false")
	assert(island.is_grid_lines_visible() == false, "Grid lines state should be false")
	var toggled_on = island.toggle_grid_lines()
	assert(toggled_on == true, "Grid lines should toggle back to true")
	island.queue_free()
	print("  PASS: IslandBase grid lines toggle verified OK")
	
	# Test 3: HUD instantiation & wiring
	print("Test 3: HUD UI Scene & Controllers...")
	var hud_scene = load("res://scenes/ui/hud.tscn")
	assert(hud_scene != null, "HUD scene loads successfully")
	var hud_node = hud_scene.instantiate() as HUD
	assert(hud_node != null, "HUD node instantiates")
	root.add_child(hud_node)
	await process_frame
	
	# Test Grid size switching
	var captured = {"size": -1}
	hud_node.grid_size_requested.connect(func(sz): captured["size"] = sz)
	hud_node._on_select_grid_size(16)
	assert(captured["size"] == 16, "Grid size 16 should be emitted")
	assert(hud_node.current_grid_size == 16, "current_grid_size should be 16")
	
	hud_node._on_select_grid_size(24)
	assert(captured["size"] == 24, "Grid size 24 should be emitted")
	
	# Test Category selection & catalog items updating
	hud_node._set_category("nature")
	assert(hud_node.current_category == "nature", "Current category should be nature")
	var child_count = hud_node.catalog_grid.get_child_count()
	assert(child_count > 0, "Catalog grid should have cards for nature")
	
	# Test Mute toggle
	var initial_muted = AudioManager.is_muted()
	hud_node._on_mute_pressed()
	assert(AudioManager.is_muted() == not initial_muted, "Mute pressed should toggle audio mute")
	hud_node._on_mute_pressed() # Restore
	
	hud_node.queue_free()
	print("  PASS: HUD controllers, grid pills, and category tabs verified OK")
	
	# Test 4: Main scene instantiation & starter island
	print("Test 4: Main Scene Integration...")
	var main_scene = load("res://scenes/main.tscn")
	assert(main_scene != null, "Main scene loads")
	var main_node = main_scene.instantiate() as Main
	assert(main_node != null, "Main node instantiates")
	root.add_child(main_node)
	await process_frame
	
	assert(main_node.grid_manager != null, "GridManager exists")
	assert(main_node.grid_manager.ground_tiles.size() > 0 or main_node.grid_manager.objects.size() > 0, "Starter island has spawned objects")
	
	# Test grid resize through Main
	main_node._on_grid_size_requested(20)
	assert(main_node.grid_manager.grid_size == 20, "Grid size updated to 20 in Main")
	
	main_node.queue_free()
	print("  PASS: Main scene integration verified OK")
	
	print("--- All Light Theme HUD & System Tests Passed Successfully! ---\n")
	quit(0)
