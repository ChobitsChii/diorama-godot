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

	if main.get("hud"):
		main.hud._on_viewport_size_changed()
	for i in range(10):
		await process_frame

	# 1. Landscape Main Building View
	var img1 = root.get_texture().get_image()
	img1.save_png("%s/raw_01_inselbau.png" % out_dir)
	print("Captured raw_01_inselbau.png")

	# 2. Category selection: switch to nature
	if main.get("hud") and main.hud.has_method("_set_category"):
		main.hud._set_category("nature")
	for i in range(12):
		await process_frame
	var img2 = root.get_texture().get_image()
	img2.save_png("%s/raw_02_baukatalog.png" % out_dir)
	print("Captured raw_02_baukatalog.png")

	# 3. Zoomed Village / Animal close-up angle with creatures category
	if main.get("hud") and main.hud.has_method("_set_category"):
		main.hud._set_category("creatures")
	if main.get("camera_controller"):
		main.camera_controller._target_yaw = PI * 0.8
		main.camera_controller._target_size = 8.5
	for i in range(25):
		await process_frame
	var img3 = root.get_texture().get_image()
	img3.save_png("%s/raw_03_dorfleben.png" % out_dir)
	print("Captured raw_03_dorfleben.png")

	# 4. Night Mode with glowing streetlamps and windows
	if main.get("day_night"):
		main.day_night.set_night(true)
	if main.get("hud") and main.hud.has_method("_set_category"):
		main.hud._set_category("deco")
	if main.get("camera_controller"):
		main.camera_controller._target_yaw = PI * 0.35
		main.camera_controller._target_size = 11.5
	for i in range(25):
		await process_frame
	var img4 = root.get_texture().get_image()
	img4.save_png("%s/raw_04_nachtmodus.png" % out_dir)
	print("Captured raw_04_nachtmodus.png")

	# 5. Mobile Portrait View
	DisplayServer.window_set_size(Vector2i(720, 1280))
	root.size = Vector2i(720, 1280)
	if main.get("day_night"):
		main.day_night.set_night(false)
	if main.get("hud") and main.hud.has_method("_set_category"):
		main.hud._set_category("buildings")
	if main.get("camera_controller"):
		main.camera_controller._target_yaw = PI / 4.0
		main.camera_controller._target_size = 12.0
	if main.get("hud"):
		main.hud._on_viewport_size_changed()
	for i in range(20):
		await process_frame
	var img5 = root.get_texture().get_image()
	img5.save_png("%s/raw_05_mobil_portrait.png" % out_dir)
	print("Captured raw_05_mobil_portrait.png")

	print("--- All Store Screenshots Captured Successfully! ---")
	quit(0)
