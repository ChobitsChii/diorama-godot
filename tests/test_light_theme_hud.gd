extends SceneTree

func _init() -> void:
	create_timer(15.0).timeout.connect(func():
		printerr("TEST TIMEOUT: test_light_theme_hud exceeded 15 seconds")
		quit(1)
	)
	call_deferred("_run_suite")

func _run_suite() -> void:
	print("\n--- Starting Light Theme HUD, Polish & System Test ---")
	
	# Test 1: Catalog items count & category coverage
	print("Test 1: Catalog Items Coverage & Aliases...")
	var categories = ["ground", "buildings", "nature", "creatures", "deco"]
	var total_items = 0
	for cat in categories:
		var items = Catalog.get_items_by_category(cat)
		assert(items.size() > 0, "Category %s has items" % cat)
		total_items += items.size()
	print("  PASS: Total Catalog items: %d across 5 categories" % total_items)
	assert(total_items >= 38, "Catalog should have at least 38 items (got %d)" % total_items)
	
	# German alias checks
	assert(Catalog.get_items_by_category("Böden").size() == Catalog.get_items_by_category("ground").size())
	assert(Catalog.get_items_by_category("Tiere").size() == Catalog.get_items_by_category("creatures").size())
	assert(Catalog.get_items_by_category("Natur").size() == Catalog.get_items_by_category("nature").size())
	assert(Catalog.get_items_by_category("Gebäude").size() == Catalog.get_items_by_category("buildings").size())
	assert(Catalog.get_items_by_category("Deko").size() == Catalog.get_items_by_category("deco").size())
	print("  PASS: Category aliases verified OK")
	
	# Test 2: Audio Volume Boost
	print("Test 2: Audio Volume & Controls...")
	assert(AudioManager.SOUND_VOLUME_DB.get("cat_meow", 0.0) >= 4.0, "cat_meow volume should be boosted by at least +4 dB")
	AudioManager.set_master_volume(0.8)
	assert(abs(AudioManager.get_master_volume() - 0.8) < 0.05, "Master volume setter/getter works")
	print("  PASS: Audio volume and +4 dB cat_meow boost verified OK")
	
	# Test 3: IslandBase 3D grid lines toggle
	print("Test 3: IslandBase 3D GridLines Toggle...")
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
	
	# Test 4: HUD UI Scene, Categories & Settings
	print("Test 4: HUD UI Scene & Categories...")
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
	
	# Wire PlacementController to HUD to test realistic category switching
	var pc_test = PlacementController.new()
	root.add_child(pc_test)
	await process_frame
	hud_node.placement_ctrl = pc_test
	
	# Test Switching EVERY Category and verifying card creation with PlacementController connected
	for cat in ["ground", "buildings", "nature", "creatures", "deco", "ground"]:
		hud_node._set_category(cat)
		assert(hud_node.current_category == cat, "Current category should be %s" % cat)
		var child_count = hud_node.catalog_grid.get_child_count()
		assert(child_count > 0, "Catalog grid should have cards for %s (got %d)" % [cat, child_count])
		
		# Inspect first card
		var first_card = hud_node.catalog_grid.get_child(0) as Button
		assert(first_card != null, "Card must be a Button")
		assert(first_card.custom_minimum_size == Vector2(100, 80), "Card minimum size must be 100x80")
		assert(not first_card.text.is_empty(), "Card text must not be empty")
		
		# Click card to verify active item selection
		var card_id = first_card.get_meta("item_id")
		first_card.emit_signal("pressed")
		assert(pc_test.active_place_type == card_id, "PlacementController active_place_type should match selected card %s" % card_id)
		assert(pc_test.active_type_id == card_id, "PlacementController active_type_id should match selected card %s" % card_id)
	print("  PASS: All 5 categories render cards correctly and update PlacementController on click")
	
	pc_test.queue_free()
	
	# Test Settings Dialog
	hud_node._on_settings_pressed()
	assert(hud_node.settings_dialog.visible == true, "Settings dialog should open")
	hud_node.settings_dialog.hide()
	
	hud_node.queue_free()
	print("  PASS: HUD controllers, grid pills, and settings dialog verified OK")
	
	# Test 5: Main scene instantiation & starter island & speech bubbles
	print("Test 5: Main Scene Integration & Explore Mode Creature Click...")
	var main_scene = load("res://scenes/main.tscn")
	assert(main_scene != null, "Main scene loads")
	var main_node = main_scene.instantiate() as Main
	assert(main_node != null, "Main node instantiates")
	root.add_child(main_node)
	await process_frame
	
	# Ensure starter island is cleanly spawned for testing
	main_node.spawn_starter_island()
	assert(main_node.grid_manager != null, "GridManager exists")
	assert(main_node.grid_manager.ground_tiles.size() > 0 or main_node.grid_manager.objects.size() > 0, "Starter island has spawned objects")
	
	# Test Explore click on creature (Cat at gx: 7, gz: 3)
	main_node.placement_controller.set_mode(PlacementController.Mode.EXPLORE)
	var cat_interacted = {"triggered": false, "speech": ""}
	main_node.placement_controller.creature_interacted.connect(func(_id, speech, _pos):
		cat_interacted["triggered"] = true
		cat_interacted["speech"] = speech
	)
	main_node.placement_controller._handle_explore_click(7, 3)
	assert(cat_interacted["triggered"] == true, "Cat click in Explore mode must trigger creature_interacted")
	assert(cat_interacted["speech"] == "Miau! 🐾", "Speech text should be 'Miau! 🐾'")
	
	# Test that HUD spawned a speech bubble
	assert(main_node.hud.speech_bubble_layer.get_child_count() > 0, "Speech bubble layer should spawn bubble on creature click")
	
	# Test Category Tab buttons directly in full Main scene
	var cat_buttons = [
		main_node.hud.cat_buildings_btn,
		main_node.hud.cat_nature_btn,
		main_node.hud.cat_creatures_btn,
		main_node.hud.cat_deco_btn,
		main_node.hud.cat_ground_btn
	]
	for btn in cat_buttons:
		btn.emit_signal("pressed")
		var count = main_node.hud.catalog_grid.get_child_count()
		assert(count > 0, "CatalogGrid must have items after clicking %s (got %d)" % [btn.text, count])
	print("  PASS: All category tab buttons clicked in Main scene and rendered cards successfully")
	
	main_node.queue_free()
	print("  PASS: Main scene explore mode creature interaction and speech bubble verified OK")
	
	print("--- All Light Theme HUD, Polish & System Tests Passed Successfully! ---\n")
	quit(0)
