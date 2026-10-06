extends SceneTree

## Headless Integration Test for Phase 2b: GridManager, Placement, Lift, Move, Demolish

func _init() -> void:
	print("--- Starting Phase 2b Headless Integration Tests ---")
	
	# Instantiate GridManager
	var grid = GridManager.new()
	grid.grid_size = 12
	grid.cell_size = 1.0
	root.add_child(grid)
	
	# Test 1: Coordinate mapping
	print("Test 1: Coordinate conversions...")
	var w_pos = grid.grid_to_world(0, 0, 1)
	assert(w_pos.is_equal_approx(Vector3(-5.5, 0.0, -5.5)), "World pos for (0,0) incorrect")
	var g_pos = grid.world_to_grid(w_pos, 1)
	assert(g_pos == Vector2i(0, 0), "Roundtrip coordinate conversion failed")
	print("  PASS: Coordinate conversions OK")
	
	# Test 2: Placing Ground Tiles (Layer 0)
	print("Test 2: Ground tile placement...")
	var grass = grid.place("grass", 3, 3)
	assert(not grass.is_empty(), "Failed to place grass tile")
	assert(grid.ground_tiles.has(Vector2i(3, 3)), "Ground tile not registered in ground_tiles dictionary")
	assert(grass["is_ground"] == true, "Grass tile should be is_ground=true")
	print("  PASS: Ground tile placement OK")
	
	# Test 3: Placing Props (Layer 1) & Stacking
	print("Test 3: Prop placement & overlap check...")
	var cottage = grid.place("cottage", 5, 5, 0)
	assert(not cottage.is_empty(), "Failed to place cottage")
	assert(grid.objects.has(cottage["id"]), "Cottage not registered in objects dictionary")
	assert(grid.cells.has(Vector2i(5, 5)), "Cell (5,5) not marked occupied")
	assert(grid.cells.has(Vector2i(6, 6)), "Cell (6,6) not marked occupied for 2x2 cottage")
	
	# Should reject placing another object overlapping the cottage
	var overlap_valid = grid.is_valid_position(5, 5, 1, "pine")
	assert(overlap_valid == false, "Overlap detection failed: allowed pine on cottage")
	print("  PASS: Prop placement & overlap check OK")
	
	# Test 4: Selection & Lift
	print("Test 4: Selection & Lift...")
	var top_item = grid.get_top_item_at(5, 5)
	assert(top_item["id"] == cottage["id"], "get_top_item_at should return cottage")
	grid.lift_item(top_item, 0.35)
	grid.drop_item(top_item)
	print("  PASS: Selection & Lift OK")
	
	# Test 5: Move item
	print("Test 5: Moving item...")
	var move_success = grid.move_item(cottage, 1, 1)
	assert(move_success == true, "Failed to move cottage to empty cell (1,1)")
	assert(grid.cells.has(Vector2i(1, 1)), "Cell (1,1) should be occupied")
	assert(not grid.cells.has(Vector2i(5, 5)), "Old cell (5,5) should be freed")
	print("  PASS: Moving item OK")
	
	# Test 6: Rotation
	print("Test 6: Item rotation...")
	var new_rot = grid.rotate_item(cottage, 1)
	assert(new_rot == 1, "Rotation step should be 1")
	assert(is_equal_approx(cottage["rotation"], PI * 0.5), "Rotation angle should be PI/2")
	print("  PASS: Item rotation OK")
	
	# Test 7: Demolish
	print("Test 7: Demolition...")
	var demo_success = grid.demolish_at(1, 1)
	assert(demo_success == true, "Failed to demolish cottage at (1,1)")
	assert(not grid.objects.has(cottage["id"]), "Cottage should be removed from objects")
	assert(not grid.cells.has(Vector2i(1, 1)), "Cell (1,1) should be freed")
	print("  PASS: Demolition OK")
	
	print("--- All Phase 2b Unit & Integration Tests Passed Successfully! ---")
	quit(0)
