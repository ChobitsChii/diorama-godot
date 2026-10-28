extends SceneTree

func _init():
	DisplayServer.window_set_size(Vector2i(1280, 720))
	var root = get_root()
	root.size = Vector2i(1280, 720)
	
	var main_scene = load("res://scenes/main.tscn")
	var main = main_scene.instantiate()
	root.add_child(main)
	
	var out_dir = "/home/jennifer/.gemini/antigravity/brain/83e4edc0-7cf1-4eee-bb13-30e6cf3aba4e"
	
	for i in range(6):
		await process_frame
	
	# 1. Exact Modulon Starter Island & HUD
	main.spawn_starter_island()
	if main.get("hud"):
		main.hud._on_viewport_size_changed()
	for i in range(26):
		await process_frame
	
	var img = root.get_texture().get_image()
	img.save_png("%s/screenshot_landscape_hud.png" % out_dir)
	print("Captured screenshot_landscape_hud.png")
	
	# 2. Showcase Water, Fields, Harvestable Plants, New Creatures & Active Harvest Basket!
	var gm: GridManager = main.grid_manager
	# Add a water stream on the front-left with an Axolotl
	gm.place("water", 3, 8)
	gm.place("water", 4, 8)
	gm.place("water", 4, 9)
	gm.place("axolotl", 4, 8)
	# Add farm fields & harvestable crops
	gm.place("field_fruit", 2, 8)
	gm.place("strawberry_plant", 2, 8)
	gm.place("field_vegetable", 2, 9)
	gm.place("potato_plant", 2, 9)
	gm.place("field_mushroom", 3, 9)
	gm.place("mushrooms", 3, 9)
	# Add Squirrel & Parrot perched in trees, plus Pig, Lion, White Tiger, Horse
	gm.place("squirrel", 3, 6)
	gm.place("parrot", 8, 9)
	gm.place("pig", 7, 8)
	gm.place("whitetiger", 6, 9)
	# Populate Harvest Basket & select Strawberry
	main.hud.basket = {"strawberry": 3, "potato": 2, "mushroom": 4, "nut": 5}
	main.hud._on_basket_slot_pressed("strawberry")
	main.hud._set_category("creatures")
	main.storage_manager.save_local()
	
	for i in range(26):
		await process_frame
	img = root.get_texture().get_image()
	img.save_png("%s/screenshot_landscape_creatures.png" % out_dir)
	print("Captured screenshot_landscape_creatures.png")
	
	# 3. Portrait / Smartphone Display Check (480x1040)
	DisplayServer.window_set_size(Vector2i(480, 1040))
	root.size = Vector2i(480, 1040)
	if main.get("hud"):
		main.hud._on_viewport_size_changed()
	for i in range(24):
		await process_frame
	img = root.get_texture().get_image()
	img.save_png("%s/screenshot_portrait_hud.png" % out_dir)
	print("Captured screenshot_portrait_hud.png")
	
	# Restore clean starter island & empty basket so user save stays clean
	DisplayServer.window_set_size(Vector2i(1280, 720))
	root.size = Vector2i(1280, 720)
	main.hud.basket = {"strawberry": 0, "potato": 0, "mushroom": 0, "nut": 0}
	main.hud.selected_food = ""
	main.hud._update_harvest_basket_ui()
	main.spawn_starter_island()
	for i in range(6):
		await process_frame
	
	print("--- Screenshot Capture Complete ---")
	quit(0)
