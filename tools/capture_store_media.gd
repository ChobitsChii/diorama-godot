extends SceneTree

func _init():
	var out_dir = "/home/jennifer/development/diorama-godot/store-media"
	DirAccess.make_dir_recursive_absolute(out_dir)

	# Start in 1280x720 Landscape
	DisplayServer.window_set_size(Vector2i(1280, 720))
	var root = get_root()
	root.size = Vector2i(1280, 720)

	var main_scene = load("res://scenes/main.tscn")
	var main = main_scene.instantiate()
	root.add_child(main)

	# Wait for ready, loading and layout
	for i in range(15):
		await process_frame

	main.spawn_starter_island()
	if main.get("hud"):
		main.hud._on_viewport_size_changed()
	for i in range(25):
		await process_frame

	# 1. Landscape Main Building View
	var img1 = root.get_texture().get_image()
	img1.save_png("%s/raw_01_inselbau.png" % out_dir)
	print("Captured raw_01_inselbau.png")

	# 2. Category selection: switch to nature + show crops & water stream
	var gm: GridManager = main.grid_manager
	gm.place("water", 3, 8)
	gm.place("water", 4, 8)
	gm.place("water", 4, 9)
	gm.place("axolotl", 4, 8)
	gm.place("field_fruit", 2, 8)
	gm.place("strawberry_plant", 2, 8)
	gm.place("field_vegetable", 2, 9)
	gm.place("potato_plant", 2, 9)
	gm.place("field_mushroom", 3, 9)
	gm.place("mushrooms", 3, 9)
	gm.place("squirrel", 3, 6)
	gm.place("parrot", 8, 9)
	gm.place("pig", 7, 8)
	gm.place("whitetiger", 6, 9)
	if main.get("hud"):
		main.hud.basket = {"strawberry": 3, "potato": 2, "mushroom": 4, "nut": 5}
		main.hud._update_harvest_basket_ui()
		main.hud._set_category("nature")
	for i in range(20):
		await process_frame
	var img2 = root.get_texture().get_image()
	img2.save_png("%s/raw_02_baukatalog.png" % out_dir)
	print("Captured raw_02_baukatalog.png")

	# 3. Zoomed Village / Animal close-up angle with creatures category & Harvest Basket active
	if main.get("hud"):
		main.hud._on_basket_slot_pressed("strawberry")
		main.hud._set_category("creatures")
	if main.get("camera_rig"):
		main.camera_rig.orbit_yaw = 52.0
		main.camera_rig.orbit_distance = 17.5
		main.camera_rig._current_yaw = 52.0
		main.camera_rig._current_distance = 17.5
		main.camera_rig._apply_transform_immediate()
	for i in range(25):
		await process_frame
	var img3 = root.get_texture().get_image()
	img3.save_png("%s/raw_03_dorfleben.png" % out_dir)
	print("Captured raw_03_dorfleben.png")

	# 4. Night Mode with glowing streetlamps and windows
	if main.get("day_night"):
		main.day_night.set_night_mode(true)
	if main.get("hud"):
		main.hud.selected_food = ""
		main.hud.selection_hint.visible = false
		main.hud._update_harvest_basket_ui()
		main.hud._set_category("deco")
	if main.get("camera_rig"):
		main.camera_rig.orbit_yaw = 38.0
		main.camera_rig.orbit_distance = 22.0
		main.camera_rig._current_yaw = 38.0
		main.camera_rig._current_distance = 22.0
		main.camera_rig._apply_transform_immediate()
	for i in range(25):
		await process_frame
	var img4 = root.get_texture().get_image()
	img4.save_png("%s/raw_04_nachtmodus.png" % out_dir)
	print("Captured raw_04_nachtmodus.png")

	# 5. Mobile Portrait View
	DisplayServer.window_set_size(Vector2i(720, 1280))
	root.size = Vector2i(720, 1280)
	if main.get("day_night"):
		main.day_night.set_night_mode(false)
	if main.get("hud"):
		main.hud._set_category("buildings")
	if main.get("camera_rig"):
		main.camera_rig.reset_view_immediate(12)
	if main.get("hud"):
		main.hud._on_viewport_size_changed()
	for i in range(25):
		await process_frame
	var img5 = root.get_texture().get_image()
	img5.save_png("%s/raw_05_mobil_portrait.png" % out_dir)
	print("Captured raw_05_mobil_portrait.png")

	# Restore clean starter state
	DisplayServer.window_set_size(Vector2i(1280, 720))
	root.size = Vector2i(1280, 720)
	main.hud.basket = {"strawberry": 0, "potato": 0, "mushroom": 0, "nut": 0}
	main.hud._update_harvest_basket_ui()
	main.spawn_starter_island()
	for i in range(6):
		await process_frame

	print("--- All Store Screenshots Captured Successfully! ---")
	quit(0)
