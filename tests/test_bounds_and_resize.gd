extends SceneTree

func _init():
	print("--- Running Boundary & Resizing Verification ---")
	var gm = GridManager.new()
	gm.grid_size = 12
	gm.ground_tiles = {}
	gm.objects = {}
	gm.cells = {}
	
	# Try placing out of bounds
	var oob_tile = gm.place("grass", -1, 0)
	assert(oob_tile.is_empty(), "OOB placement (-1, 0) must be rejected")
	var oob_obj = gm.place("cottage", 12, 12)
	assert(oob_obj.is_empty(), "OOB placement (12, 12) must be rejected")
	var oob_edge = gm.place("cottage", 11, 11) # cottage is 2x2, requires 11 and 12 -> 12 is out of bounds for 12x12 (0..11)
	assert(oob_edge.is_empty(), "OOB 2x2 cottage at boundary must be rejected")
	
	# Place valid item inside
	var ok_tile = gm.place("grass", 5, 5)
	assert(not ok_tile.is_empty(), "In-bounds tile must succeed")
	assert(gm.ground_tiles.has(Vector2i(5, 5)), "Tile stored at Vector2i(5, 5)")
	
	# Place valid 2x2 building
	var ok_bldg = gm.place("cottage", 4, 4)
	assert(not ok_bldg.is_empty(), "In-bounds 2x2 building must succeed")
	var bldg_id = ok_bldg["id"]
	assert(gm.objects.has(bldg_id), "Building stored in objects")
	assert(gm.cells.has(Vector2i(4, 4)), "Cell 4,4 occupied")
	assert(gm.cells.has(Vector2i(5, 5)), "Cell 5,5 occupied by cottage")
	
	# Resize grid: from 12 to 16 (delta = (16-12)/2 = +2)
	gm.set_grid_size(16)
	assert(gm.ground_tiles.has(Vector2i(7, 7)), "Tile shifted to Vector2i(7, 7)")
	assert(gm.objects[bldg_id]["gx"] == 6 and gm.objects[bldg_id]["gz"] == 6, "Building shifted to 6,6")
	assert(gm.cells.has(Vector2i(6, 6)), "Cell 6,6 occupied after shift")
	
	# Resize down: from 16 to 8 (delta = (8-16)/2 = -4)
	# 7,7 shifted by -4 -> 3,3 (within 8x8: 0..7)
	# 6,6 shifted by -4 -> 2,2 (within 8x8: 0..7)
	gm.set_grid_size(8)
	assert(gm.ground_tiles.has(Vector2i(3, 3)), "Tile shifted to Vector2i(3, 3)")
	assert(gm.objects[bldg_id]["gx"] == 2 and gm.objects[bldg_id]["gz"] == 2, "Building shifted to 2,2")
	
	# Place 1x1 pine at edge (7,7) in 8x8
	var edge_pine = gm.place("pine", 7, 7)
	assert(not edge_pine.is_empty(), "Edge pine placed at 7,7")
	var pine_id = edge_pine["id"]
	assert(gm.objects.has(pine_id), "Pine stored in objects")
	
	# Shrink to 6x6 (delta = (6-8)/2 = -1) -> pine at 7,7 shifted to 6,6, which is >= 6 -> culled!
	gm.set_grid_size(6)
	assert(not gm.objects.has(pine_id), "Out-of-bounds pine after shrink must be culled")
	gm.clear_all()
	gm.queue_free()
	print("  PASS: Boundary verification and resizing shifts/culling OK")
	quit(0)
