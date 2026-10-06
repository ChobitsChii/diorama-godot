class_name HUD
extends Control

## Light Theme Bau-HUD matching Web Diorama (42px slim TopBar, Brand Pill,
## 5-Pill Grid Switcher, Settings Dialog, Comic Speech Bubbles, and High-Contrast Catalog Cards).

signal tool_selected(mode: int)
signal category_selected(cat: String)
signal item_chosen(type_id: String)
signal grid_size_requested(new_size: int)
signal reset_island_requested()

# TopBar nodes
@onready var top_bar: PanelContainer = %TopBar
@onready var brand_pill: PanelContainer = %BrandPill
@onready var status_label: Label = %StatusLabel

# Grid size pill group
@onready var grid_size_group: PanelContainer = %GridSizeGroup
@onready var btn_grid_8: Button = %BtnGrid8
@onready var btn_grid_12: Button = %BtnGrid12
@onready var btn_grid_16: Button = %BtnGrid16
@onready var btn_grid_20: Button = %BtnGrid20
@onready var btn_grid_24: Button = %BtnGrid24

# Top controls (Cleaned up for Mobile: Foto, Info, Optionen)
@onready var btn_snapshot: Button = %BtnSnapshot
@onready var btn_info: Button = %BtnInfo
@onready var btn_settings: Button = %BtnSettings

# Overlays & Feedback
@onready var selection_hint: PanelContainer = %SelectionHint
@onready var selection_hint_label: Label = %SelectionHintLabel
@onready var toast_panel: PanelContainer = %ToastPanel
@onready var toast_label: Label = %ToastLabel
@onready var flash_rect: ColorRect = %FlashRect
@onready var speech_bubble_layer: Control = %SpeechBubbleLayer

# Sidebar nodes
@onready var sidebar_wrapper: Control = %SidebarWrapper
@onready var sidebar_panel: PanelContainer = %SidebarPanel
@onready var btn_toggle_sidebar: Button = %BtnToggleSidebar
@onready var tools_grid: GridContainer = %ToolsGrid

# Tools
@onready var btn_tool_explore: Button = %BtnToolExplore
@onready var btn_tool_select: Button = %BtnToolSelect
@onready var btn_tool_place: Button = %BtnToolPlace
@onready var btn_tool_rotate: Button = %BtnToolRotate
@onready var btn_tool_demolish: Button = %BtnToolDemolish
@onready var btn_undo: Button = %BtnUndo
@onready var btn_redo: Button = %BtnRedo

# Category Tabs
@onready var cat_ground_btn: Button = %CatGroundBtn
@onready var cat_buildings_btn: Button = %CatBuildingsBtn
@onready var cat_nature_btn: Button = %CatNatureBtn
@onready var cat_creatures_btn: Button = %CatCreaturesBtn
@onready var cat_deco_btn: Button = %CatDecoBtn
@onready var category_title_label: Label = %CategoryTitleLabel

# Catalog Grid & Scroll
@onready var scroll_container: ScrollContainer = $SidebarWrapper/SidebarPanel/Margin/VBox/ScrollContainer
@onready var catalog_grid: GridContainer = %CatalogGrid

# Dialogs
@onready var reset_confirm_dialog: ConfirmationDialog = %ResetConfirmDialog
@onready var credits_dialog: AcceptDialog = %CreditsDialog
@onready var settings_dialog: AcceptDialog = %SettingsDialog

# Settings Controls
@onready var slider_master: HSlider = %SliderMaster
@onready var check_mute: CheckBox = %CheckMute
@onready var check_grid_lines: CheckBox = %CheckGridLines
@onready var check_night_mode: CheckBox = %CheckNightMode
@onready var btn_reset_cam_settings: Button = %BtnResetCamSettings
@onready var btn_save_settings: Button = %BtnSaveSettings
@onready var btn_load_settings: Button = %BtnLoadSettings
@onready var btn_reset_island_settings: Button = %BtnResetIslandSettings

# Controllers
var placement_ctrl: PlacementController
var day_night_ctrl: DayNightController
var camera_ctrl: CameraController
var storage_mgr: StorageManager
var history_mgr: HistoryManager
var sync_mgr: SyncManager
var island_base: IslandBase

var current_category: String = "ground"
var is_sidebar_open: bool = true
var is_portrait_mode: bool = false
const SIDEBAR_WIDTH: float = 284.0

var current_grid_size: int = 12
var _toast_tween: Tween

# UI Styles (Light Theme)
var _style_pill_normal: StyleBoxFlat
var _style_pill_hover: StyleBoxFlat
var _style_pill_active: StyleBoxFlat

var _style_action_pill: StyleBoxFlat
var _style_action_pill_hover: StyleBoxFlat

var _style_tool_normal: StyleBoxFlat
var _style_tool_hover: StyleBoxFlat
var _style_tool_active: StyleBoxFlat
var _style_tool_danger_active: StyleBoxFlat

var _style_cat_normal: StyleBoxFlat
var _style_cat_hover: StyleBoxFlat
var _style_cat_active: StyleBoxFlat

var _style_card_normal: StyleBoxFlat
var _style_card_hover: StyleBoxFlat
var _style_card_selected: StyleBoxFlat

var _style_sidebar_landscape: StyleBoxFlat
var _style_sidebar_portrait: StyleBoxFlat

func _ready() -> void:
	_init_styles()
	_connect_signals()
	_setup_grid_size_buttons()
	_setup_top_action_buttons()
	_update_category_buttons()
	_update_catalog_items("ground")
	
	if selection_hint:
		selection_hint.visible = false
	if toast_panel:
		toast_panel.visible = false
	if flash_rect:
		flash_rect.color.a = 0.0
	
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	_on_viewport_size_changed()

func setup_all(
	pc: PlacementController,
	dn: DayNightController,
	cc: CameraController,
	sm: StorageManager,
	hm: HistoryManager,
	sync: SyncManager,
	ib: IslandBase = null
) -> void:
	placement_ctrl = pc
	day_night_ctrl = dn
	camera_ctrl = cc
	storage_mgr = sm
	history_mgr = hm
	sync_mgr = sync
	island_base = ib
	
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

func _init_styles() -> void:
	# 1. Pill Buttons (TopBar Grid Switcher)
	_style_pill_normal = StyleBoxFlat.new()
	_style_pill_normal.bg_color = Color(0.94, 0.955, 0.975, 0.9)
	_style_pill_normal.set_corner_radius_all(9999)
	
	_style_pill_hover = StyleBoxFlat.new()
	_style_pill_hover.bg_color = Color(0.88, 0.92, 0.97, 1.0)
	_style_pill_hover.set_corner_radius_all(9999)
	
	_style_pill_active = StyleBoxFlat.new()
	_style_pill_active.bg_color = Color(0.145, 0.388, 0.922, 1.0) # #2563eb
	_style_pill_active.border_width_left = 1
	_style_pill_active.border_width_top = 1
	_style_pill_active.border_width_right = 1
	_style_pill_active.border_width_bottom = 1
	_style_pill_active.border_color = Color(0.114, 0.306, 0.847, 1.0)
	_style_pill_active.set_corner_radius_all(9999)
	_style_pill_active.shadow_size = 4
	_style_pill_active.shadow_color = Color(0.145, 0.388, 0.922, 0.35)
	
	# Action buttons (Foto, Info, Optionen)
	_style_action_pill = StyleBoxFlat.new()
	_style_action_pill.bg_color = Color(1.0, 1.0, 1.0, 0.92)
	_style_action_pill.border_width_left = 1
	_style_action_pill.border_width_top = 1
	_style_action_pill.border_width_right = 1
	_style_action_pill.border_width_bottom = 1
	_style_action_pill.border_color = Color(0.85, 0.88, 0.92, 1.0)
	_style_action_pill.set_corner_radius_all(9999)
	_style_action_pill.shadow_size = 2
	_style_action_pill.shadow_color = Color(0, 0, 0, 0.04)
	
	_style_action_pill_hover = StyleBoxFlat.new()
	_style_action_pill_hover.bg_color = Color(0.93, 0.96, 1.0, 1.0)
	_style_action_pill_hover.border_width_left = 1
	_style_action_pill_hover.border_width_top = 1
	_style_action_pill_hover.border_width_right = 1
	_style_action_pill_hover.border_width_bottom = 1
	_style_action_pill_hover.border_color = Color(0.576, 0.773, 0.992, 1.0)
	_style_action_pill_hover.set_corner_radius_all(9999)
	_style_action_pill_hover.shadow_size = 4
	_style_action_pill_hover.shadow_color = Color(0.145, 0.388, 0.922, 0.15)
	
	# 2. Tool Buttons
	_style_tool_normal = StyleBoxFlat.new()
	_style_tool_normal.bg_color = Color(0.97, 0.98, 0.99, 1.0)
	_style_tool_normal.border_width_left = 1
	_style_tool_normal.border_width_top = 1
	_style_tool_normal.border_width_right = 1
	_style_tool_normal.border_width_bottom = 1
	_style_tool_normal.border_color = Color(0.886, 0.910, 0.941, 1.0)
	_style_tool_normal.set_corner_radius_all(10)
	
	_style_tool_hover = StyleBoxFlat.new()
	_style_tool_hover.bg_color = Color(0.93, 0.96, 1.0, 1.0)
	_style_tool_hover.border_width_left = 1
	_style_tool_hover.border_width_top = 1
	_style_tool_hover.border_width_right = 1
	_style_tool_hover.border_width_bottom = 1
	_style_tool_hover.border_color = Color(0.576, 0.773, 0.992, 1.0)
	_style_tool_hover.set_corner_radius_all(10)
	
	_style_tool_active = StyleBoxFlat.new()
	_style_tool_active.bg_color = Color(0.145, 0.388, 0.922, 1.0)
	_style_tool_active.border_width_left = 1
	_style_tool_active.border_width_top = 1
	_style_tool_active.border_width_right = 1
	_style_tool_active.border_width_bottom = 1
	_style_tool_active.border_color = Color(0.114, 0.306, 0.847, 1.0)
	_style_tool_active.set_corner_radius_all(10)
	_style_tool_active.shadow_size = 4
	_style_tool_active.shadow_color = Color(0.145, 0.388, 0.922, 0.35)
	
	_style_tool_danger_active = StyleBoxFlat.new()
	_style_tool_danger_active.bg_color = Color(0.863, 0.149, 0.149, 1.0)
	_style_tool_danger_active.border_width_left = 1
	_style_tool_danger_active.border_width_top = 1
	_style_tool_danger_active.border_width_right = 1
	_style_tool_danger_active.border_width_bottom = 1
	_style_tool_danger_active.border_color = Color(0.725, 0.110, 0.110, 1.0)
	_style_tool_danger_active.set_corner_radius_all(10)
	_style_tool_danger_active.shadow_size = 4
	_style_tool_danger_active.shadow_color = Color(0.863, 0.149, 0.149, 0.35)
	
	# 3. Category Pills
	_style_cat_normal = StyleBoxFlat.new()
	_style_cat_normal.bg_color = Color(0.95, 0.965, 0.98, 0.6)
	_style_cat_normal.set_corner_radius_all(8)
	
	_style_cat_hover = StyleBoxFlat.new()
	_style_cat_hover.bg_color = Color(0.9, 0.93, 0.98, 1.0)
	_style_cat_hover.set_corner_radius_all(8)
	
	_style_cat_active = StyleBoxFlat.new()
	_style_cat_active.bg_color = Color(0.878, 0.906, 1.0, 1.0)
	_style_cat_active.border_width_left = 1
	_style_cat_active.border_width_top = 1
	_style_cat_active.border_width_right = 1
	_style_cat_active.border_width_bottom = 1
	_style_cat_active.border_color = Color(0.506, 0.55, 0.988, 1.0)
	_style_cat_active.set_corner_radius_all(8)
	
	# 4. Catalog Cards (High-contrast 100x80)
	_style_card_normal = StyleBoxFlat.new()
	_style_card_normal.bg_color = Color(1.0, 1.0, 1.0, 1.0)
	_style_card_normal.border_width_left = 1
	_style_card_normal.border_width_top = 1
	_style_card_normal.border_width_right = 1
	_style_card_normal.border_width_bottom = 1
	_style_card_normal.border_color = Color(0.886, 0.910, 0.941, 1.0)
	_style_card_normal.set_corner_radius_all(12)
	_style_card_normal.shadow_size = 2
	_style_card_normal.shadow_color = Color(0, 0, 0, 0.03)
	
	_style_card_hover = StyleBoxFlat.new()
	_style_card_hover.bg_color = Color(1.0, 1.0, 1.0, 1.0)
	_style_card_hover.border_width_left = 1
	_style_card_hover.border_width_top = 1
	_style_card_hover.border_width_right = 1
	_style_card_hover.border_width_bottom = 1
	_style_card_hover.border_color = Color(0.576, 0.773, 0.992, 1.0)
	_style_card_hover.set_corner_radius_all(12)
	_style_card_hover.shadow_size = 6
	_style_card_hover.shadow_color = Color(0.23, 0.51, 0.96, 0.12)
	
	_style_card_selected = StyleBoxFlat.new()
	_style_card_selected.bg_color = Color(0.937, 0.965, 1.0, 1.0)
	_style_card_selected.border_width_left = 2
	_style_card_selected.border_width_top = 2
	_style_card_selected.border_width_right = 2
	_style_card_selected.border_width_bottom = 2
	_style_card_selected.border_color = Color(0.145, 0.388, 0.922, 1.0)
	_style_card_selected.set_corner_radius_all(12)
	_style_card_selected.shadow_size = 6
	_style_card_selected.shadow_color = Color(0.145, 0.388, 0.922, 0.2)
	
	# 5. Sidebar Panel Styles
	_style_sidebar_landscape = StyleBoxFlat.new()
	_style_sidebar_landscape.bg_color = Color(0.98, 0.985, 0.995, 0.95)
	_style_sidebar_landscape.border_width_left = 1
	_style_sidebar_landscape.border_width_top = 1
	_style_sidebar_landscape.border_width_bottom = 1
	_style_sidebar_landscape.border_color = Color(1, 1, 1, 0.85)
	_style_sidebar_landscape.corner_radius_top_left = 18
	_style_sidebar_landscape.corner_radius_bottom_left = 18
	_style_sidebar_landscape.shadow_color = Color(0, 0, 0, 0.1)
	_style_sidebar_landscape.shadow_size = 12
	
	_style_sidebar_portrait = StyleBoxFlat.new()
	_style_sidebar_portrait.bg_color = Color(0.98, 0.985, 0.995, 0.95)
	_style_sidebar_portrait.border_width_left = 1
	_style_sidebar_portrait.border_width_top = 1
	_style_sidebar_portrait.border_width_right = 1
	_style_sidebar_portrait.border_color = Color(1, 1, 1, 0.85)
	_style_sidebar_portrait.corner_radius_top_left = 18
	_style_sidebar_portrait.corner_radius_top_right = 18
	_style_sidebar_portrait.shadow_color = Color(0, 0, 0, 0.1)
	_style_sidebar_portrait.shadow_size = 12

func _connect_signals() -> void:
	# Tools
	btn_tool_explore.pressed.connect(func(): _on_tool_btn_pressed(PlacementController.Mode.EXPLORE))
	btn_tool_select.pressed.connect(func(): _on_tool_btn_pressed(PlacementController.Mode.SELECT))
	btn_tool_place.pressed.connect(func(): _on_tool_btn_pressed(PlacementController.Mode.PLACE))
	btn_tool_rotate.pressed.connect(_on_rotate_btn_pressed)
	btn_tool_demolish.pressed.connect(func(): _on_tool_btn_pressed(PlacementController.Mode.DEMOLISH))
	
	btn_undo.pressed.connect(_on_undo_pressed)
	btn_redo.pressed.connect(_on_redo_pressed)
	
	# Categories
	cat_ground_btn.pressed.connect(func(): _set_category("ground"))
	cat_buildings_btn.pressed.connect(func(): _set_category("buildings"))
	cat_nature_btn.pressed.connect(func(): _set_category("nature"))
	cat_creatures_btn.pressed.connect(func(): _set_category("creatures"))
	cat_deco_btn.pressed.connect(func(): _set_category("deco"))
	
	# Sidebar toggle
	btn_toggle_sidebar.pressed.connect(_toggle_sidebar)
	
	# Top Controls
	btn_snapshot.pressed.connect(_on_snapshot_pressed)
	btn_info.pressed.connect(_on_info_pressed)
	btn_settings.pressed.connect(_on_settings_pressed)
	
	# Settings Dialog controls
	slider_master.value_changed.connect(_on_master_slider_changed)
	check_mute.toggled.connect(_on_check_mute_toggled)
	check_grid_lines.toggled.connect(_on_check_grid_lines_toggled)
	check_night_mode.toggled.connect(_on_check_night_mode_toggled)
	btn_reset_cam_settings.pressed.connect(_on_reset_camera_pressed)
	btn_save_settings.pressed.connect(_on_save_pressed)
	btn_load_settings.pressed.connect(_on_load_pressed)
	btn_reset_island_settings.pressed.connect(_on_reset_pressed)
	reset_confirm_dialog.confirmed.connect(_on_reset_confirmed)

func _setup_top_action_buttons() -> void:
	_apply_action_button_theme(btn_snapshot)
	_apply_action_button_theme(btn_info)
	_apply_action_button_theme(btn_settings)

func _apply_action_button_theme(btn: Button) -> void:
	if not btn:
		return
	btn.add_theme_stylebox_override("normal", _style_action_pill)
	btn.add_theme_stylebox_override("hover", _style_action_pill_hover)
	btn.add_theme_stylebox_override("pressed", _style_pill_active)
	btn.add_theme_stylebox_override("focus", _style_action_pill)
	btn.add_theme_color_override("font_color", Color(0.2, 0.25, 0.35, 1.0))
	btn.add_theme_color_override("font_hover_color", Color(0.08, 0.12, 0.2, 1.0))
	btn.add_theme_color_override("font_pressed_color", Color(1.0, 1.0, 1.0, 1.0))
	btn.add_theme_color_override("font_focus_color", Color(0.2, 0.25, 0.35, 1.0))

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
	btn_tool_explore.button_pressed = (active_mode == PlacementController.Mode.EXPLORE)
	btn_tool_select.button_pressed = (active_mode == PlacementController.Mode.SELECT)
	btn_tool_place.button_pressed = (active_mode == PlacementController.Mode.PLACE)
	btn_tool_demolish.button_pressed = (active_mode == PlacementController.Mode.DEMOLISH)
	
	_apply_tool_style(btn_tool_explore, active_mode == PlacementController.Mode.EXPLORE)
	_apply_tool_style(btn_tool_select, active_mode == PlacementController.Mode.SELECT)
	_apply_tool_style(btn_tool_place, active_mode == PlacementController.Mode.PLACE)
	_apply_tool_style(btn_tool_demolish, active_mode == PlacementController.Mode.DEMOLISH, true)
	
	if camera_ctrl:
		camera_ctrl.is_explore_mode = (active_mode == PlacementController.Mode.EXPLORE)

func _apply_tool_style(btn: Button, is_active: bool, is_danger: bool = false) -> void:
	if not btn:
		return
	if is_active:
		var st = _style_tool_danger_active if is_danger else _style_tool_active
		btn.add_theme_stylebox_override("normal", st)
		btn.add_theme_stylebox_override("hover", st)
		btn.add_theme_stylebox_override("pressed", st)
		btn.add_theme_stylebox_override("focus", st)
		btn.add_theme_color_override("font_color", Color.WHITE)
		btn.add_theme_color_override("font_hover_color", Color.WHITE)
		btn.add_theme_color_override("font_pressed_color", Color.WHITE)
		btn.add_theme_color_override("font_focus_color", Color.WHITE)
	else:
		btn.add_theme_stylebox_override("normal", _style_tool_normal)
		btn.add_theme_stylebox_override("hover", _style_tool_hover)
		btn.add_theme_stylebox_override("pressed", _style_tool_normal)
		btn.add_theme_stylebox_override("focus", _style_tool_normal)
		btn.add_theme_color_override("font_color", Color(0.2, 0.25, 0.35, 1.0))
		btn.add_theme_color_override("font_hover_color", Color(0.06, 0.09, 0.16, 1.0))
		btn.add_theme_color_override("font_pressed_color", Color(1.0, 1.0, 1.0, 1.0))
		btn.add_theme_color_override("font_focus_color", Color(0.2, 0.25, 0.35, 1.0))

func _update_category_buttons() -> void:
	var tabs = {
		"ground": cat_ground_btn,
		"buildings": cat_buildings_btn,
		"nature": cat_nature_btn,
		"creatures": cat_creatures_btn,
		"deco": cat_deco_btn,
	}
	for cat in tabs:
		var btn = tabs[cat]
		if btn:
			var active = (current_category == cat)
			btn.button_pressed = active
			if active:
				btn.add_theme_stylebox_override("normal", _style_cat_active)
				btn.add_theme_stylebox_override("hover", _style_cat_active)
				btn.add_theme_stylebox_override("pressed", _style_cat_active)
				btn.add_theme_stylebox_override("focus", _style_cat_active)
				btn.add_theme_color_override("font_color", Color(0.22, 0.18, 0.64, 1.0))
				btn.add_theme_color_override("font_hover_color", Color(0.22, 0.18, 0.64, 1.0))
				btn.add_theme_color_override("font_pressed_color", Color(1.0, 1.0, 1.0, 1.0))
				btn.add_theme_color_override("font_focus_color", Color(0.22, 0.18, 0.64, 1.0))
			else:
				btn.add_theme_stylebox_override("normal", _style_cat_normal)
				btn.add_theme_stylebox_override("hover", _style_cat_hover)
				btn.add_theme_stylebox_override("pressed", _style_cat_normal)
				btn.add_theme_stylebox_override("focus", _style_cat_normal)
				btn.add_theme_color_override("font_color", Color(0.28, 0.33, 0.41, 1.0))
				btn.add_theme_color_override("font_hover_color", Color(0.08, 0.12, 0.2, 1.0))
				btn.add_theme_color_override("font_pressed_color", Color(1.0, 1.0, 1.0, 1.0))
				btn.add_theme_color_override("font_focus_color", Color(0.28, 0.33, 0.41, 1.0))

func _update_catalog_items(category: String) -> void:
	if not catalog_grid:
		catalog_grid = get_node_or_null("%CatalogGrid")
	if not catalog_grid:
		return
	
	for child in catalog_grid.get_children():
		child.queue_free()
	
	var items = Catalog.get_items_by_category(category)
	var cat_labels = {
		"ground": "🌱 Böden",
		"buildings": "🏡 Gebäude",
		"nature": "🌲 Natur",
		"creatures": "🐾 Tiere",
		"deco": "💡 Dekoration",
	}
	if category_title_label:
		category_title_label.text = "%s (%d Items)" % [cat_labels.get(category, category.capitalize()), items.size()]
	
	var active_type = placement_ctrl.active_place_type if placement_ctrl else ""
	
	for item in items:
		var card = Button.new()
		card.custom_minimum_size = Vector2(100, 80)
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		card.focus_mode = Control.FOCUS_NONE
		
		# Robust multiline text rendering
		card.text = "%s\n%s" % [item.get("icon", "📦"), item.get("name", "Item")]
		card.alignment = HORIZONTAL_ALIGNMENT_CENTER
		card.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		card.add_theme_font_size_override("font_size", 12)
		card.add_theme_constant_override("line_spacing", 4)
		
		var type_id: String = item["id"]
		var is_selected = (type_id == active_type)
		_apply_card_style(card, is_selected)
		
		card.pressed.connect(func(): _on_catalog_item_selected(type_id))
		card.set_meta("item_id", type_id)
		catalog_grid.add_child(card)

func _apply_card_style(card: Button, is_selected: bool) -> void:
	if is_selected:
		card.add_theme_stylebox_override("normal", _style_card_selected)
		card.add_theme_stylebox_override("hover", _style_card_selected)
		card.add_theme_stylebox_override("pressed", _style_card_selected)
		card.add_theme_stylebox_override("focus", _style_card_selected)
		card.add_theme_color_override("font_color", Color(0.114, 0.306, 0.847, 1.0))
		card.add_theme_color_override("font_hover_color", Color(0.114, 0.306, 0.847, 1.0))
		card.add_theme_color_override("font_pressed_color", Color(0.114, 0.306, 0.847, 1.0))
		card.add_theme_color_override("font_focus_color", Color(0.114, 0.306, 0.847, 1.0))
	else:
		card.add_theme_stylebox_override("normal", _style_card_normal)
		card.add_theme_stylebox_override("hover", _style_card_hover)
		card.add_theme_stylebox_override("pressed", _style_card_selected)
		card.add_theme_stylebox_override("focus", _style_card_normal)
		card.add_theme_color_override("font_color", Color(0.12, 0.16, 0.23, 1.0))
		card.add_theme_color_override("font_hover_color", Color(0.06, 0.09, 0.16, 1.0))
		card.add_theme_color_override("font_pressed_color", Color(0.145, 0.388, 0.922, 1.0))
		card.add_theme_color_override("font_focus_color", Color(0.12, 0.16, 0.23, 1.0))

func _on_catalog_item_selected(type_id: String) -> void:
	if placement_ctrl:
		placement_ctrl.set_active_place_type(type_id)
	_update_tool_buttons(PlacementController.Mode.PLACE)
	_refresh_catalog_cards_selection(type_id)

func _refresh_catalog_cards_selection(active_type: String) -> void:
	if not catalog_grid:
		return
	for child in catalog_grid.get_children():
		if child is Button and child.has_meta("item_id"):
			var card_id = child.get_meta("item_id")
			_apply_card_style(child, card_id == active_type)

# -----------------------------------------------------------------------------
# Grid Size Pill Switcher (Perfect Contrast)
# -----------------------------------------------------------------------------
func _setup_grid_size_buttons() -> void:
	var btns = {
		8: btn_grid_8,
		12: btn_grid_12,
		16: btn_grid_16,
		20: btn_grid_20,
		24: btn_grid_24,
	}
	for sz in btns:
		var btn = btns[sz]
		if btn:
			btn.pressed.connect(func(): _on_select_grid_size(sz))
	_update_grid_size_pills(12)

func _on_select_grid_size(sz: int) -> void:
	current_grid_size = sz
	_update_grid_size_pills(sz)
	grid_size_requested.emit(sz)
	show_toast("📐 Rastergröße: %d×%d" % [sz, sz])

func _update_grid_size_pills(active_sz: int) -> void:
	var btns = {
		8: btn_grid_8,
		12: btn_grid_12,
		16: btn_grid_16,
		20: btn_grid_20,
		24: btn_grid_24,
	}
	for sz in btns:
		var btn = btns[sz]
		if btn:
			var is_active = (sz == active_sz)
			if is_active:
				btn.add_theme_stylebox_override("normal", _style_pill_active)
				btn.add_theme_stylebox_override("hover", _style_pill_active)
				btn.add_theme_stylebox_override("pressed", _style_pill_active)
				btn.add_theme_stylebox_override("focus", _style_pill_active)
				btn.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))
				btn.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 1.0, 1.0))
				btn.add_theme_color_override("font_pressed_color", Color(1.0, 1.0, 1.0, 1.0))
				btn.add_theme_color_override("font_focus_color", Color(1.0, 1.0, 1.0, 1.0))
			else:
				btn.add_theme_stylebox_override("normal", _style_pill_normal)
				btn.add_theme_stylebox_override("hover", _style_pill_hover)
				btn.add_theme_stylebox_override("pressed", _style_pill_hover)
				btn.add_theme_stylebox_override("focus", _style_pill_normal)
				btn.add_theme_color_override("font_color", Color(0.2, 0.25, 0.35, 1.0))
				btn.add_theme_color_override("font_hover_color", Color(0.08, 0.12, 0.2, 1.0))
				btn.add_theme_color_override("font_pressed_color", Color(1.0, 1.0, 1.0, 1.0))
				btn.add_theme_color_override("font_focus_color", Color(0.2, 0.25, 0.35, 1.0))

# -----------------------------------------------------------------------------
# Speech Bubble Effect (Comic Pop-up)
# -----------------------------------------------------------------------------
func show_speech_bubble(text: String, world_pos: Vector3) -> void:
	if not speech_bubble_layer:
		speech_bubble_layer = get_node_or_null("%SpeechBubbleLayer")
	if not speech_bubble_layer:
		return
	if not camera_ctrl or not camera_ctrl.camera:
		return
	var cam: Camera3D = camera_ctrl.camera
	if not is_instance_valid(cam) or not cam.is_inside_tree():
		return
	
	var spawn_pos = world_pos + Vector3(0, 0.85, 0)
	# Strict check: object must be in front of the camera plane
	if cam.is_position_behind(spawn_pos):
		return
	
	var vp = cam.get_viewport()
	if not vp:
		return
	var vp_rect = vp.get_visible_rect()
	if vp_rect.size.x <= 0 or vp_rect.size.y <= 0:
		return
	
	var screen_pos = cam.unproject_position(spawn_pos)
	if screen_pos == Vector2.ZERO:
		return
	
	var bubble = PanelContainer.new()
	bubble.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(1.0, 1.0, 1.0, 0.96)
	sb.set_corner_radius_all(14)
	sb.border_width_left = 1
	sb.border_width_top = 1
	sb.border_width_right = 1
	sb.border_width_bottom = 1
	sb.border_color = Color(0.82, 0.86, 0.92, 1.0)
	sb.shadow_size = 8
	sb.shadow_color = Color(0, 0, 0, 0.12)
	sb.content_margin_left = 12
	sb.content_margin_right = 12
	sb.content_margin_top = 6
	sb.content_margin_bottom = 6
	bubble.add_theme_stylebox_override("panel", sb)
	
	var lbl = Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", 14)
	lbl.add_theme_color_override("font_color", Color(0.1, 0.14, 0.22, 1.0))
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bubble.add_child(lbl)
	
	speech_bubble_layer.add_child(bubble)
	
	bubble.position = screen_pos - Vector2(bubble.size.x * 0.5, bubble.size.y)
	bubble.pivot_offset = Vector2(bubble.size.x * 0.5, bubble.size.y)
	bubble.scale = Vector2.ZERO
	
	# Pop and float animation
	var tween = create_tween()
	tween.tween_property(bubble, "scale", Vector2(1.15, 1.15), 0.14).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(bubble, "scale", Vector2.ONE, 0.10).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(bubble, "position:y", bubble.position.y - 25.0, 1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	# Fade out after 1.1 seconds
	tween.chain().tween_interval(0.9)
	tween.tween_property(bubble, "modulate:a", 0.0, 0.35)
	tween.tween_callback(bubble.queue_free)

# -----------------------------------------------------------------------------
# Top Controls & Settings Handlers
# -----------------------------------------------------------------------------
func _on_settings_pressed() -> void:
	# Synchronize state with current engine values
	slider_master.value = AudioManager.get_master_volume()
	check_mute.button_pressed = AudioManager.is_muted()
	if island_base:
		check_grid_lines.button_pressed = island_base.is_grid_lines_visible()
	if day_night_ctrl:
		check_night_mode.button_pressed = day_night_ctrl.is_night
	
	settings_dialog.popup_centered(Vector2i(460, 490))

func _on_master_slider_changed(val: float) -> void:
	AudioManager.set_master_volume(val)

func _on_check_mute_toggled(pressed: bool) -> void:
	if pressed != AudioManager.is_muted():
		AudioManager.toggle_mute()

func _on_check_grid_lines_toggled(pressed: bool) -> void:
	if island_base:
		island_base.set_grid_lines_visible(pressed)

func _on_check_night_mode_toggled(pressed: bool) -> void:
	if day_night_ctrl and day_night_ctrl.is_night != pressed:
		day_night_ctrl.toggle()

func _on_snapshot_pressed() -> void:
	if flash_rect:
		flash_rect.color.a = 0.85
		var tween = create_tween()
		tween.tween_property(flash_rect, "color:a", 0.0, 0.35)
	
	AudioManager.play("click")
	
	await get_tree().process_frame
	var img = get_viewport().get_texture().get_image()
	if img:
		var dir_path = "user://screenshots"
		DirAccess.make_dir_absolute(dir_path)
		var ts = Time.get_datetime_string_from_system().replace(":", "-")
		var file_path = "%s/diorama_%s.png" % [dir_path, ts]
		var err = img.save_png(file_path)
		if err == OK:
			show_toast("📸 Foto aufgenommen & gespeichert! ✓")
		else:
			show_toast("⚠️ Fehler beim Speichern des Fotos")

func _on_reset_pressed() -> void:
	reset_confirm_dialog.popup_centered()

func _on_reset_confirmed() -> void:
	reset_island_requested.emit()
	show_toast("🔄 Diorama auf Starter-Insel zurückgesetzt ✓")

func _on_info_pressed() -> void:
	credits_dialog.popup_centered(Vector2i(500, 420))

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

func _on_reset_camera_pressed() -> void:
	if camera_ctrl:
		camera_ctrl.reset_view()

# -----------------------------------------------------------------------------
# Controller Callbacks
# -----------------------------------------------------------------------------
func _on_placement_mode_changed(mode: int) -> void:
	_update_tool_buttons(mode)

func _on_selection_changed(has_selection: bool, entry: Dictionary) -> void:
	if not selection_hint:
		return
	selection_hint.visible = has_selection
	if has_selection:
		var item_name: String = entry.get("type", "Objekt")
		var def = Catalog.get_item(entry.get("type", ""))
		if not def.is_empty():
			item_name = def.get("name", item_name)
		if selection_hint_label:
			selection_hint_label.text = "✋ [%s] Klick: Absetzen • [R] Drehen • [Entf] Löschen • [Esc] Abbrechen" % item_name

func _on_time_changed(is_night: bool) -> void:
	if check_night_mode:
		check_night_mode.set_pressed_no_signal(is_night)

func _on_history_changed(can_undo: bool, can_redo: bool) -> void:
	if btn_undo:
		btn_undo.disabled = not can_undo
	if btn_redo:
		btn_redo.disabled = not can_redo

func _on_storage_status_changed(status: String) -> void:
	if not status_label:
		return
	match status:
		"saved":
			status_label.text = "• 💾 Gespeichert"
		"saving":
			status_label.text = "• ⏳ Speichern..."
		"loaded":
			status_label.text = "• 📂 Geladen"
		"error":
			status_label.text = "• ⚠️ Fehler"

func _on_sync_finished(action: String, success: bool, _message: String) -> void:
	if action == "save" and success and status_label:
		status_label.text = "• ☁️ Synchronisiert ✓"

func show_toast(msg: String, duration: float = 2.0) -> void:
	if not toast_label:
		toast_label = get_node_or_null("%ToastLabel")
		if not toast_label:
			toast_label = get_node_or_null("ToastPanel/Margin/ToastLabel")
	if not toast_panel:
		toast_panel = get_node_or_null("%ToastPanel")
	if not toast_label or not toast_panel:
		return
	toast_label.text = msg
	toast_panel.visible = true
	toast_panel.modulate.a = 1.0
	
	if _toast_tween and _toast_tween.is_valid():
		_toast_tween.kill()
	_toast_tween = create_tween()
	if _toast_tween:
		_toast_tween.tween_interval(duration)
		_toast_tween.tween_property(toast_panel, "modulate:a", 0.0, 0.4)
		_toast_tween.tween_callback(func():
			if is_instance_valid(toast_panel):
				toast_panel.visible = false
		)

# -----------------------------------------------------------------------------
# Responsive Layout & Safe Area
# -----------------------------------------------------------------------------
func _on_viewport_size_changed() -> void:
	var vp_size = get_viewport().get_visible_rect().size
	if vp_size.y <= 0 or vp_size.x <= 0:
		return
	var is_portrait = (vp_size.y > vp_size.x)
	is_portrait_mode = is_portrait
	
	_apply_safe_area_and_layout(vp_size, is_portrait)

func _apply_safe_area_and_layout(vp_size: Vector2, is_portrait: bool) -> void:
	var safe_area: Rect2i = DisplayServer.get_display_safe_area()
	var top_inset: float = 0.0
	var bottom_inset: float = 0.0
	var left_inset: float = 0.0
	var right_inset: float = 0.0
	
	if safe_area.size.x > 0 and safe_area.size.y > 0 and (safe_area.size.x < vp_size.x or safe_area.size.y < vp_size.y):
		top_inset = max(0.0, float(safe_area.position.y))
		left_inset = max(0.0, float(safe_area.position.x))
		right_inset = max(0.0, vp_size.x - float(safe_area.position.x + safe_area.size.x))
		bottom_inset = max(0.0, vp_size.y - float(safe_area.position.y + safe_area.size.y))
	
	if top_bar:
		top_bar.offset_top = 10.0 + top_inset
		top_bar.offset_bottom = 52.0 + top_inset
		top_bar.offset_left = 12.0 + left_inset
		top_bar.offset_right = -(12.0 + right_inset)
	
	if is_portrait:
		_apply_portrait_layout(left_inset, right_inset, bottom_inset)
	else:
		_apply_landscape_layout(top_inset, bottom_inset, right_inset)

func _apply_landscape_layout(top_inset: float, bottom_inset: float, right_inset: float) -> void:
	if not sidebar_wrapper or not btn_toggle_sidebar:
		return
	
	if sidebar_panel:
		sidebar_panel.add_theme_stylebox_override("panel", _style_sidebar_landscape)
	
	sidebar_wrapper.anchor_left = 1.0
	sidebar_wrapper.anchor_top = 0.0
	sidebar_wrapper.anchor_right = 1.0
	sidebar_wrapper.anchor_bottom = 1.0
	
	sidebar_wrapper.offset_top = 60.0 + top_inset
	sidebar_wrapper.offset_bottom = -(12.0 + bottom_inset)
	sidebar_wrapper.offset_left = -(SIDEBAR_WIDTH + right_inset) if is_sidebar_open else 0.0
	sidebar_wrapper.offset_right = -right_inset if is_sidebar_open else (SIDEBAR_WIDTH + right_inset)
	
	btn_toggle_sidebar.anchor_left = 0.0
	btn_toggle_sidebar.anchor_top = 0.0
	btn_toggle_sidebar.anchor_right = 0.0
	btn_toggle_sidebar.anchor_bottom = 0.0
	btn_toggle_sidebar.offset_left = -34.0
	btn_toggle_sidebar.offset_right = -1.0
	btn_toggle_sidebar.offset_top = 12.0
	btn_toggle_sidebar.offset_bottom = 50.0
	btn_toggle_sidebar.text = "▶" if is_sidebar_open else "◀"

func _apply_portrait_layout(left_inset: float, right_inset: float, bottom_inset: float) -> void:
	if not sidebar_wrapper or not btn_toggle_sidebar:
		return
	
	if sidebar_panel:
		sidebar_panel.add_theme_stylebox_override("panel", _style_sidebar_portrait)
	
	sidebar_wrapper.anchor_left = 0.0
	sidebar_wrapper.anchor_top = 1.0
	sidebar_wrapper.anchor_right = 1.0
	sidebar_wrapper.anchor_bottom = 1.0
	
	var dock_height = 280.0
	sidebar_wrapper.offset_left = 8.0 + left_inset
	sidebar_wrapper.offset_right = -(8.0 + right_inset)
	sidebar_wrapper.offset_top = -(dock_height + bottom_inset) if is_sidebar_open else 0.0
	sidebar_wrapper.offset_bottom = -bottom_inset if is_sidebar_open else dock_height
	
	btn_toggle_sidebar.anchor_left = 0.9
	btn_toggle_sidebar.anchor_top = 0.0
	btn_toggle_sidebar.anchor_right = 0.9
	btn_toggle_sidebar.anchor_bottom = 0.0
	btn_toggle_sidebar.offset_left = -34.0
	btn_toggle_sidebar.offset_right = 4.0
	btn_toggle_sidebar.offset_top = -36.0
	btn_toggle_sidebar.offset_bottom = -2.0
	btn_toggle_sidebar.text = "▼" if is_sidebar_open else "▲"

func _toggle_sidebar() -> void:
	is_sidebar_open = not is_sidebar_open
	var tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	if is_portrait_mode:
		var target_top = -280.0 if is_sidebar_open else 0.0
		var target_bottom = 0.0 if is_sidebar_open else 280.0
		tween.tween_property(sidebar_wrapper, "offset_top", target_top, 0.22)
		tween.tween_property(sidebar_wrapper, "offset_bottom", target_bottom, 0.22)
		btn_toggle_sidebar.text = "▼" if is_sidebar_open else "▲"
	else:
		var target_left = -SIDEBAR_WIDTH if is_sidebar_open else 0.0
		var target_right = 0.0 if is_sidebar_open else SIDEBAR_WIDTH
		tween.tween_property(sidebar_wrapper, "offset_left", target_left, 0.22)
		tween.tween_property(sidebar_wrapper, "offset_right", target_right, 0.22)
		btn_toggle_sidebar.text = "▶" if is_sidebar_open else "◀"
