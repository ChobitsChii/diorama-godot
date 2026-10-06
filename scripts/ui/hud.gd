class_name HUD
extends Control

## Adaptive Bau-HUD with responsive sidebar (Desktop) vs bottom dock (Mobile Portrait), category tabs, and selection hint.

signal tool_selected(mode: int)
signal category_selected(cat: String)
signal item_chosen(type_id: String)
signal rotate_clicked()
signal day_night_clicked()
signal reset_camera_clicked()

@onready var top_bar: PanelContainer = %TopBar
@onready var selection_hint: PanelContainer = %SelectionHint
@onready var selection_hint_label: Label = %SelectionHintLabel

@onready var sidebar: PanelContainer = %Sidebar
@onready var btn_toggle_sidebar: Button = %BtnToggleSidebar
@onready var tools_container: HBoxContainer = %ToolsContainer

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
@onready var btn_day_night: Button = %BtnDayNight
@onready var btn_reset_camera: Button = %BtnResetCamera

var current_category: String = "ground"
var is_sidebar_open: bool = true
var is_portrait_mode: bool = false

var placement_ctrl: PlacementController
var day_night_ctrl: DayNightController
var camera_ctrl: CameraController

func _ready() -> void:
	_connect_signals()
	_update_catalog_items("ground")
	selection_hint.visible = false
	
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	_on_viewport_size_changed()

func setup_controllers(pc: PlacementController, dn: DayNightController, cc: CameraController) -> void:
	placement_ctrl = pc
	day_night_ctrl = dn
	camera_ctrl = cc
	
	if placement_ctrl:
		placement_ctrl.mode_changed.connect(_on_placement_mode_changed)
		placement_ctrl.selection_changed.connect(_on_selection_changed)
	
	if day_night_ctrl:
		day_night_ctrl.time_changed.connect(_on_time_changed)

func _connect_signals() -> void:
	btn_tool_select.pressed.connect(func(): _on_tool_btn_pressed(PlacementController.Mode.SELECT))
	btn_tool_place.pressed.connect(func(): _on_tool_btn_pressed(PlacementController.Mode.PLACE))
	btn_tool_rotate.pressed.connect(_on_rotate_btn_pressed)
	btn_tool_demolish.pressed.connect(func(): _on_tool_btn_pressed(PlacementController.Mode.DEMOLISH))
	
	cat_ground_btn.pressed.connect(func(): _set_category("ground"))
	cat_buildings_btn.pressed.connect(func(): _set_category("buildings"))
	cat_nature_btn.pressed.connect(func(): _set_category("nature"))
	cat_creatures_btn.pressed.connect(func(): _set_category("creatures"))
	cat_deco_btn.pressed.connect(func(): _set_category("deco"))
	
	btn_toggle_sidebar.pressed.connect(_toggle_sidebar)
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
		btn.custom_minimum_size = Vector2(120, 44)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.add_theme_font_size_override("font_size", 13)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		var type_id: String = item["id"]
		btn.pressed.connect(func(): _on_catalog_item_selected(type_id))
		catalog_grid.add_child(btn)

func _on_catalog_item_selected(type_id: String) -> void:
	if placement_ctrl:
		placement_ctrl.set_active_place_type(type_id)
	_update_tool_buttons(PlacementController.Mode.PLACE)

# -----------------------------------------------------------------------------
# Controller Signals
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

func _on_day_night_pressed() -> void:
	if day_night_ctrl:
		day_night_ctrl.toggle()

func _on_reset_camera_pressed() -> void:
	if camera_ctrl:
		camera_ctrl.reset_view()

# -----------------------------------------------------------------------------
# Responsive Layout Handling (Desktop Landscape vs. Mobile Portrait)
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
	sidebar.anchor_left = 1.0
	sidebar.anchor_top = 0.12
	sidebar.anchor_right = 1.0
	sidebar.anchor_bottom = 0.98
	sidebar.offset_left = -310.0 if is_sidebar_open else 0.0
	sidebar.offset_right = -10.0 if is_sidebar_open else 300.0
	sidebar.offset_top = 0.0
	sidebar.offset_bottom = 0.0
	
	btn_toggle_sidebar.text = "▶" if is_sidebar_open else "◀"
	catalog_grid.columns = 2

func _apply_portrait_layout() -> void:
	# Bottom horizontal dock for smartphones
	sidebar.anchor_left = 0.02
	sidebar.anchor_top = 1.0
	sidebar.anchor_right = 0.98
	sidebar.anchor_bottom = 1.0
	sidebar.offset_left = 0.0
	sidebar.offset_right = 0.0
	sidebar.offset_top = -250.0 if is_sidebar_open else -44.0
	sidebar.offset_bottom = -10.0
	
	btn_toggle_sidebar.text = "▼" if is_sidebar_open else "▲"
	catalog_grid.columns = 3

func _toggle_sidebar() -> void:
	is_sidebar_open = not is_sidebar_open
	var tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	if is_portrait_mode:
		var target_top = -250.0 if is_sidebar_open else -44.0
		tween.tween_property(sidebar, "offset_top", target_top, 0.2)
		btn_toggle_sidebar.text = "▼" if is_sidebar_open else "▲"
	else:
		var target_left = -310.0 if is_sidebar_open else 0.0
		var target_right = -10.0 if is_sidebar_open else 300.0
		tween.tween_property(sidebar, "offset_left", target_left, 0.2)
		tween.tween_property(sidebar, "offset_right", target_right, 0.2)
		btn_toggle_sidebar.text = "▶" if is_sidebar_open else "◀"
