extends SceneTree

func _init():
	DisplayServer.window_set_size(Vector2i(480, 1040))
	var root = get_root()
	root.size = Vector2i(480, 1040)
	
	var main_scene = load("res://scenes/main.tscn")
	var main = main_scene.instantiate()
	root.add_child(main)
	
	var out_dir = "/home/jennifer/.gemini/antigravity/brain/83e4edc0-7cf1-4eee-bb13-30e6cf3aba4e"
	
	# Wait for ready and layout
	for i in range(6):
		await process_frame
	
	if main.get("hud"):
		main.hud._on_viewport_size_changed()
	for i in range(6):
		await process_frame
	
	# 1. Main HUD Portrait Screenshot
	var img = root.get_texture().get_image()
	img.save_png("%s/screenshot_portrait_hud.png" % out_dir)
	print("Captured screenshot_portrait_hud.png")
	
	# 2. Settings Dialog Screenshot
	main.hud._on_settings_pressed()
	for i in range(6):
		await process_frame
	img = root.get_texture().get_image()
	img.save_png("%s/screenshot_portrait_settings.png" % out_dir)
	print("Captured screenshot_portrait_settings.png")
	main.hud.settings_dialog.hide()
	
	# 3. Credits Dialog Screenshot
	main.hud._on_info_pressed()
	for i in range(6):
		await process_frame
	img = root.get_texture().get_image()
	img.save_png("%s/screenshot_portrait_credits.png" % out_dir)
	print("Captured screenshot_portrait_credits.png")
	main.hud.credits_dialog.hide()
	
	print("--- Screenshot Capture Complete ---")
	quit(0)
