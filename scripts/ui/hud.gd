class_name HUD
extends Control

## Adaptive Bau-HUD with responsive sidebar, category tabs, Undo/Redo, local Save/Load, and floating hint.

signal tool_selected(mode: int)
signal category_selected(cat: String)
signal item_chosen(type_id: String)

@onready var top_bar: PanelContainer = %TopBar
@onready var selection_hint: PanelContainer = %SelectionHint
@onready var selection_hint_label: Label = %SelectionHintLabel
@onready var toast_panel: PanelContainer = %ToastPanel
@onready var toast_label: Label = %ToastLabel

# Sidebar nodes
@onready var sidebar_wrapper: Control = %SidebarWrapper
@onready var sidebar_panel: PanelContainer = %SidebarPanel
@onready var btn_toggle_sidebar: Button = %BtnToggleSidebar
@onready var tools_grid: GridContainer = %ToolsGrid

# Tool buttons
@onready var btn_tool_select: Button = %BtnToolSelect
@onready var btn_tool_place: Button = %BtnToolPlace
@onready var btn_tool_rotate: Button = %BtnToolRotate
@onready var btn_tool_demolish: Button = %BtnToolDemolish

# Category buttons
@onready var cat_ground_btn: Button = %CatGroundBtn
@onready var cat_buildings_btn: Button = %CatBuildingsBtn
@onready var cat_nature_btn: Button = %CatNatureBtn
@onready var cat_creatures_btn: Button = %CatCreaturesBtn
@onready var cat_deco_btn: Button = %CatDecoBtn

# Catalog item grid
@onready var catalog_grid: GridContainer = %CatalogGrid

# Top bar buttons
@onready var btn_undo: Button = %BtnUndo
@onready var btn_redo: Button = %BtnRedo
@onready var btn_save: Button = %BtnSave
@onready var btn_load: Button = %BtnLoad
@onready var btn_day_night: Button = %BtnDayNight
@onready var btn_reset_camera: Button = %BtnResetCamera
@onready var status_label: Label = %StatusLabel

var current_category: String = "ground"
var is_sidebar_open: bool = true
var is_portrait_mode: bool = false
const SIDEBAR_WIDTH: float = 280.0

var placement_ctrl: PlacementController
var day_night_ctrl: DayNightController
var camera_ctrl: CameraController
var storage_mgr: StorageManager
var history_mgr: HistoryManager
var sync_mgr: SyncManager

var _toast_tween: Tween

func _ready() -> void:
	_connect_signals()
	_update_catalog_items("ground")
	selection_hint.visible = false
	toast_panel.visible = false
	
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	_on_viewport_size_changed()

func setup_all(
	pc: PlacementController,
	dn: DayNightController,
	cc: CameraController,
	sm: StorageManager,
	hm: HistoryManager,
	sync: SyncManager
) -> void:
	placement_ctrl = pc
	day_night_ctrl = dn
	camera_ctrl = cc
	storage_mgr = sm
	history_mgr = hm
	sync_mgr = sync
	
	if placement_ctrl:
		placement_ctrl.mode_changed.connect(_on_placement_mode_changed)
		placement_ctrl.selection_changed.connect(_on_selection_changed)
	
	if day_night_ctrl:
		day_night_ctrl.time_changed.connect(_on_time_changed)
	
	if history_mgr:
		history_mgr.history_changed.connect(_on_history_changed)
		_on_history_changed(history_mgr.can_undo(), history_mgr.can_redo())
	
	if storage_mgr:
		storage_mgr.save_status_changed.connect(_on_storage_status_changed)
	
	if sync_mgr:
		sync_mgr.sync_finished.connect(_on_sync_finished)

func _connect_signals() -> void:
	# Tools
	btn_tool_select.pressed.connect(func(): _on_tool_btn_pressed(PlacementController.Mode.SELECT))
	btn_tool_place.pressed.connect(func(): _on_tool_btn_pressed(PlacementController.Mode.PLACE))
	btn_tool_rotate.pressed.connect(_on_rotate_btn_pressed)
	btn_tool_demolish.pressed.connect(func(): _on_tool_btn_pressed(PlacementController.Mode.DEMOLISH))
	
	# Categories
	cat_ground_btn.pressed.connect(func(): _set_category("ground"))
	cat_buildings_btn.pressed.connect(func(): _set_category("buildings"))
	cat_nature_btn.pressed.connect(func(): _set_category("nature"))
	cat_creatures_btn.pressed.connect(func(): _set_category("creatures"))
	cat_deco_btn.pressed.connect(func(): _set_category("deco"))
	
	# Sidebar toggle
	btn_toggle_sidebar.pressed.connect(_toggle_sidebar)
	
	# Top bar
	btn_undo.pressed.connect(_on_undo_pressed)
	btn_redo.pressed.connect(_on_redo_pressed)
	btn_save.pressed.connect(_on_save_pressed)
	btn_load.pressed.connect(_on_load_pressed)
	btn_day_night.pressed.connect(_on_day_night_pressed)
	btn_reset_camera.pressed.connect(_on_reset_camera_pressed)

# -----------------------------------------------------------------------------
# Tool and Category Handlers
# -----------------------------------------------------------------------------
func _on_tool_btn_pressed(mode: int) -> void:
	if placement_ctrl:
		placement_ctrl.set_mode(mode)
	_update_tool_buttons(mode)

func _on_rotate_btn_pressed() -> void:
	if placement_ctrl:
		placement_ctrl.rotate_active()

func _set_category(cat: String) -> void:
	current_category = cat
	_update_category_buttons()
	_update_catalog_items(cat)

func _update_tool_buttons(active_mode: int) -> void:
	btn_tool_select.button_pressed = (active_mode == PlacementController.Mode.SELECT)
	btn_tool_place.button_pressed = (active_mode == PlacementController.Mode.PLACE)
	btn_tool_demolish.button_pressed = (active_mode == PlacementController.Mode.DEMOLISH)

func _update_category_buttons() -> void:
	cat_ground_btn.button_pressed = (current_category == "ground")
	cat_buildings_btn.button_pressed = (current_category == "buildings")
	cat_nature_btn.button_pressed = (current_category == "nature")
	cat_creatures_btn.button_pressed = (current_category == "creatures")
	cat_deco_btn.button_pressed = (current_category == "deco")

func _update_catalog_items(category: String) -> void:
	for child in catalog_grid.get_children():
		child.queue_free()
	
	var items = Catalog.get_items_by_category(category)
	for item in items:
		var btn = Button.new()
		btn.text = "%s %s" % [item.get("icon", "📦"), item.get("name", "Item")]
		btn.custom_minimum_size = Vector2(110, 40)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.add_theme_font_size_override("font_size", 12)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		var type_id: String = item["id"]
		btn.pressed.connect(func(): _on_catalog_item_selected(type_id))
		catalog_grid.add_child(btn)

func _on_catalog_item_selected(type_id: String) -> void:
	if placement_ctrl:
		placement_ctrl.set_active_place_type(type_id)
	_update_tool_buttons(PlacementController.Mode.PLACE)

# -----------------------------------------------------------------------------
# Top Bar Actions (Save, Load, Undo, Redo, Night)
# -----------------------------------------------------------------------------
func _on_undo_pressed() -> void:
	if history_mgr and history_mgr.undo():
		show_toast("↩️ Aktion rückgängig gemacht")

func _on_redo_pressed() -> void:
	if history_mgr and history_mgr.redo():
		show_toast("↪️ Aktion wiederholt")

func _on_save_pressed() -> void:
	if storage_mgr:
		var ok = storage_mgr.save_local()
		if ok:
			show_toast("💾 Insel lokal gespeichert ✓")
			# Also initiate async cloud sync if available
			if sync_mgr and storage_mgr.grid_manager:
				sync_mgr.sync_to_cloud(storage_mgr.grid_manager)

func _on_load_pressed() -> void:
	if storage_mgr:
		if storage_mgr.has_save_file():
			var ok = storage_mgr.load_local()
			if ok:
				show_toast("📂 Speicherstand geladen ✓")
		else:
			show_toast("ℹ️ Kein lokaler Speicherstand vorhanden")

func _on_day_night_pressed() -> void:
	if day_night_ctrl:
		day_night_ctrl.toggle()

func _on_reset_camera_pressed() -> void:
	if camera_ctrl:
		camera_ctrl.reset_view()

# -----------------------------------------------------------------------------
# Signals from Controllers
# -----------------------------------------------------------------------------
func _on_placement_mode_changed(mode: int) -> void:
	_update_tool_buttons(mode)

func _on_selection_changed(has_selection: bool, entry: Dictionary) -> void:
	selection_hint.visible = has_selection
	if has_selection:
		var item_name: String = entry.get("type", "Objekt")
		var def = Catalog.get_item(entry.get("type", ""))
		if not def.is_empty():
			item_name = def.get("name", item_name)
		selection_hint_label.text = "✋ [%s] Klick: Absetzen • [R] Drehen • [Entf] Löschen • [Esc] Abbrechen" % item_name

func _on_time_changed(is_night: bool) -> void:
	btn_day_night.text = "☀️ Tag" if is_night else "🌙 Nacht"

func _on_history_changed(can_undo: bool, can_redo: bool) -> void:
	btn_undo.disabled = not can_undo
	btn_redo.disabled = not can_redo

func _on_storage_status_changed(status: String) -> void:
	match status:
		"saved":
			status_label.text = "💾 Gespeichert"
		"saving":
			status_label.text = "⏳ Speichern..."
		"loaded":
			status_label.text = "📂 Geladen"
		"error":
			status_label.text = "⚠️ Fehler"

func _on_sync_finished(action: String, success: bool, message: String) -> void:
	if action == "save" and success:
		status_label.text = "☁️ Synchronisiert ✓"

func show_toast(msg: String, duration: float = 2.0) -> void:
	toast_label.text = msg
	toast_panel.visible = true
	toast_panel.modulate.a = 1.0
	
	if _toast_tween and _toast_tween.is_valid():
		_toast_tween.kill()
	_toast_tween = create_tween()
	_toast_tween.tween_interval(duration)
	_toast_tween.tween_property(toast_panel, "modulate:a", 0.0, 0.4)
	_toast_tween.tween_callback(func(): toast_panel.visible = false)

# -----------------------------------------------------------------------------
# Responsive Layout & Pull-Tab Animation
# -----------------------------------------------------------------------------
func _on_viewport_size_changed() -> void:
	var vp_size = get_viewport().get_visible_rect().size
	if vp_size.y <= 0:
		return
	var is_portrait = (vp_size.y > vp_size.x)
	is_portrait_mode = is_portrait
	
	if is_portrait:
		_apply_portrait_layout()
	else:
		_apply_landscape_layout()

func _apply_landscape_layout() -> void:
	# Right vertical sidebar
	sidebar_wrapper.anchor_left = 1.0
	sidebar_wrapper.anchor_top = 0.11
	sidebar_wrapper.anchor_right = 1.0
	sidebar_wrapper.anchor_bottom = 0.98
	sidebar_wrapper.offset_left = -SIDEBAR_WIDTH if is_sidebar_open else 0.0
	sidebar_wrapper.offset_right = 0.0 if is_sidebar_open else SIDEBAR_WIDTH
	sidebar_wrapper.offset_top = 0.0
	sidebar_wrapper.offset_bottom = 0.0
	
	# Tab button positioned at the left edge of the sidebar
	btn_toggle_sidebar.anchor_left = 0.0
	btn_toggle_sidebar.anchor_top = 0.05
	btn_toggle_sidebar.anchor_right = 0.0
	btn_toggle_sidebar.anchor_bottom = 0.05
	btn_toggle_sidebar.offset_left = -34.0
	btn_toggle_sidebar.offset_right = -4.0
	btn_toggle_sidebar.offset_top = 0.0
	btn_toggle_sidebar.offset_bottom = 36.0
	btn_toggle_sidebar.text = "▶" if is_sidebar_open else "◀"

func _apply_portrait_layout() -> void:
	# Bottom horizontal dock for smartphones
	sidebar_wrapper.anchor_left = 0.02
	sidebar_wrapper.anchor_top = 1.0
	sidebar_wrapper.anchor_right = 0.98
	sidebar_wrapper.anchor_bottom = 1.0
	sidebar_wrapper.offset_left = 0.0
	sidebar_wrapper.offset_right = 0.0
	sidebar_wrapper.offset_top = -260.0 if is_sidebar_open else 0.0
	sidebar_wrapper.offset_bottom = 0.0 if is_sidebar_open else 260.0
	
	# Tab button positioned at the top-right of the dock
	btn_toggle_sidebar.anchor_left = 0.9
	btn_toggle_sidebar.anchor_top = 0.0
	btn_toggle_sidebar.anchor_right = 0.9
	btn_toggle_sidebar.anchor_bottom = 0.0
	btn_toggle_sidebar.offset_left = -34.0
	btn_toggle_sidebar.offset_right = 4.0
	btn_toggle_sidebar.offset_top = -34.0
	btn_toggle_sidebar.offset_bottom = -4.0
	btn_toggle_sidebar.text = "▼" if is_sidebar_open else "▲"

func _toggle_sidebar() -> void:
	is_sidebar_open = not is_sidebar_open
	var tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	if is_portrait_mode:
		var target_top = -260.0 if is_sidebar_open else 0.0
		var target_bottom = 0.0 if is_sidebar_open else 260.0
		tween.tween_property(sidebar_wrapper, "offset_top", target_top, 0.22)
		tween.tween_property(sidebar_wrapper, "offset_bottom", target_bottom, 0.22)
		btn_toggle_sidebar.text = "▼" if is_sidebar_open else "▲"
	else:
		var target_left = -SIDEBAR_WIDTH if is_sidebar_open else 0.0
		var target_right = 0.0 if is_sidebar_open else SIDEBAR_WIDTH
		tween.tween_property(sidebar_wrapper, "offset_left", target_left, 0.22)
		tween.tween_property(sidebar_wrapper, "offset_right", target_right, 0.22)
		btn_toggle_sidebar.text = "▶" if is_sidebar_open else "◀"
