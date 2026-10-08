class_name HUD
extends Control

## Light Theme Bau-HUD matching Web Diorama (42px slim TopBar, Brand Pill,
## 5-Pill Grid Switcher, Settings Dialog, Comic Speech Bubbles, and High-Contrast Catalog Cards).

var ICON_INFO = load("res://assets/icons/info.svg")
var ICON_SETTINGS = load("res://assets/icons/settings.svg")
var ICON_CAMERA = load("res://assets/icons/camera.svg")
var ICON_TEAM = load("res://assets/icons/team.svg")
var ICON_LICENSE = load("res://assets/icons/license.svg")
var ICON_CHECK_UNCHECKED = load("res://assets/icons/checkbox_unchecked.svg")
var ICON_CHECK_CHECKED = load("res://assets/icons/checkbox_checked.svg")
var ICON_SLIDER_GRABBER = load("res://assets/icons/slider_grabber.svg")
var ICON_SLIDER_GRABBER_HL = load("res://assets/icons/slider_grabber_hl.svg")
var ICON_WIN_CLOSE = load("res://assets/icons/window_close.svg")
var ICON_WIN_CLOSE_HL = load("res://assets/icons/window_close_pressed.svg")


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
@onready var tools_label: Label = get_node_or_null("SidebarWrapper/SidebarPanel/Margin/VBox/ToolsLabel")
@onready var h_separator_1: HSeparator = get_node_or_null("SidebarWrapper/SidebarPanel/Margin/VBox/HSeparator1")
@onready var cat_section_label: Label = get_node_or_null("SidebarWrapper/SidebarPanel/Margin/VBox/CatSectionLabel")
@onready var category_tabs: HBoxContainer = get_node_or_null("SidebarWrapper/SidebarPanel/Margin/VBox/CategoryTabs")
@onready var h_separator_2: HSeparator = get_node_or_null("SidebarWrapper/SidebarPanel/Margin/VBox/HSeparator2")

# Dialogs
@onready var reset_confirm_dialog: ConfirmationDialog = %ResetConfirmDialog
@onready var credits_dialog: AcceptDialog = %CreditsDialog
@onready var settings_dialog: AcceptDialog = %SettingsDialog
@onready var credits_text: RichTextLabel = %CreditsText

# Settings Controls
@onready var slider_master: HSlider = %SliderMaster
@onready var check_mute: CheckBox = %CheckMute
@onready var check_grid_lines: CheckBox = %CheckGridLines
@onready var check_night_mode: CheckBox = %CheckNightMode
@onready var btn_reset_cam_settings: Button = %BtnResetCamSettings
@onready var btn_save_settings: Button = %BtnSaveSettings
@onready var btn_load_settings: Button = %BtnLoadSettings
@onready var btn_open_screenshots: Button = %BtnOpenScreenshots
@onready var btn_reset_island_settings: Button = %BtnResetIslandSettings

var _pending_snapshot_image: Image = null
var _save_file_dialog: FileDialog = null

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

var _style_dialog_panel: StyleBoxFlat
var _style_dialog_btn: StyleBoxFlat
var _style_dialog_btn_hover: StyleBoxFlat
var _style_dialog_btn_danger: StyleBoxFlat
var _style_dialog_ok_btn: StyleBoxFlat

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
	
	if not get_viewport().size_changed.is_connected(_on_viewport_size_changed):
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
	_style_action_pill.content_margin_left = 10
	_style_action_pill.content_margin_right = 10
	_style_action_pill.content_margin_top = 4
	_style_action_pill.content_margin_bottom = 4
	
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
	_style_action_pill_hover.content_margin_left = 10
	_style_action_pill_hover.content_margin_right = 10
	_style_action_pill_hover.content_margin_top = 4
	_style_action_pill_hover.content_margin_bottom = 4
	
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
	
	# 6. Dialog Light Theme Styles
	_style_dialog_panel = StyleBoxFlat.new()
	_style_dialog_panel.bg_color = Color(0.985, 0.988, 0.995, 0.98)
	_style_dialog_panel.border_width_left = 1
	_style_dialog_panel.border_width_top = 1
	_style_dialog_panel.border_width_right = 1
	_style_dialog_panel.border_width_bottom = 1
	_style_dialog_panel.border_color = Color(0.85, 0.88, 0.92, 1.0)
	_style_dialog_panel.set_corner_radius_all(18)
	_style_dialog_panel.shadow_color = Color(0, 0, 0, 0.18)
	_style_dialog_panel.shadow_size = 16
	_style_dialog_panel.content_margin_left = 18
	_style_dialog_panel.content_margin_top = 14
	_style_dialog_panel.content_margin_right = 18
	_style_dialog_panel.content_margin_bottom = 32
	
	_style_dialog_btn = StyleBoxFlat.new()
	_style_dialog_btn.bg_color = Color(1.0, 1.0, 1.0, 0.95)
	_style_dialog_btn.border_width_left = 1
	_style_dialog_btn.border_width_top = 1
	_style_dialog_btn.border_width_right = 1
	_style_dialog_btn.border_width_bottom = 1
	_style_dialog_btn.border_color = Color(0.82, 0.86, 0.91, 1.0)
	_style_dialog_btn.set_corner_radius_all(10)
	_style_dialog_btn.shadow_size = 2
	_style_dialog_btn.shadow_color = Color(0, 0, 0, 0.04)
	
	_style_dialog_btn_hover = StyleBoxFlat.new()
	_style_dialog_btn_hover.bg_color = Color(0.93, 0.96, 1.0, 1.0)
	_style_dialog_btn_hover.border_width_left = 1
	_style_dialog_btn_hover.border_width_top = 1
	_style_dialog_btn_hover.border_width_right = 1
	_style_dialog_btn_hover.border_width_bottom = 1
	_style_dialog_btn_hover.border_color = Color(0.25, 0.55, 0.95, 0.8)
	_style_dialog_btn_hover.set_corner_radius_all(10)
	
	_style_dialog_btn_danger = StyleBoxFlat.new()
	_style_dialog_btn_danger.bg_color = Color(0.99, 0.95, 0.95, 1.0)
	_style_dialog_btn_danger.border_width_left = 1
	_style_dialog_btn_danger.border_width_top = 1
	_style_dialog_btn_danger.border_width_right = 1
	_style_dialog_btn_danger.border_width_bottom = 1
	_style_dialog_btn_danger.border_color = Color(0.95, 0.65, 0.65, 0.9)
	_style_dialog_btn_danger.set_corner_radius_all(10)
	
	_style_dialog_ok_btn = StyleBoxFlat.new()
	_style_dialog_ok_btn.bg_color = Color(0.145, 0.388, 0.922, 1.0)
	_style_dialog_ok_btn.set_corner_radius_all(12)
	_style_dialog_ok_btn.shadow_size = 6
	_style_dialog_ok_btn.shadow_color = Color(0.145, 0.388, 0.922, 0.35)

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
	if btn_open_screenshots:
		btn_open_screenshots.pressed.connect(_on_open_screenshots_pressed)
	reset_confirm_dialog.confirmed.connect(_on_reset_confirmed)
	reset_confirm_dialog.canceled.connect(_on_reset_canceled)

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
	tool_selected.emit(mode)

func _on_rotate_btn_pressed() -> void:
	if placement_ctrl:
		placement_ctrl.rotate_active()

func _set_category(cat: String) -> void:
	current_category = cat
	_update_category_buttons()
	_update_catalog_items(cat)
	category_selected.emit(cat)

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
		catalog_grid.remove_child(child)
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
	
	var active_type: String = ""
	if placement_ctrl:
		if "active_place_type" in placement_ctrl:
			active_type = str(placement_ctrl.active_place_type)
		elif "active_type_id" in placement_ctrl:
			active_type = str(placement_ctrl.active_type_id)
	
	for item in items:
		var card = Button.new()
		card.custom_minimum_size = Vector2(100, 80)
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		card.focus_mode = Control.FOCUS_NONE
		
		# Robust multiline text rendering with responsive sizing
		card.text = "%s\n%s" % [item.get("icon", "📦"), item.get("name", "Item")]
		card.alignment = HORIZONTAL_ALIGNMENT_CENTER
		card.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		if is_portrait_mode:
			card.custom_minimum_size = Vector2(160, 130)
			card.add_theme_font_size_override("font_size", 26)
			card.add_theme_constant_override("line_spacing", 8)
		else:
			card.custom_minimum_size = Vector2(100, 80)
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
	item_chosen.emit(type_id)

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
# Responsive Dialog Helpers
# -----------------------------------------------------------------------------
func _get_responsive_dialog_size(landscape_size: Vector2i, portrait_size: Vector2i) -> Vector2i:
	var vp_size = get_viewport().get_visible_rect().size
	if is_portrait_mode:
		var max_w = int(vp_size.x * 0.94)
		var max_h = int(vp_size.y * 0.86)
		var target_w = clampi(portrait_size.x, mini(340, max_w), max_w)
		var target_h = clampi(portrait_size.y, mini(340, max_h), max_h)
		return Vector2i(target_w, target_h)
	else:
		var max_w = int(vp_size.x * 0.85)
		var max_h = int(vp_size.y * 0.85)
		var target_w = clampi(landscape_size.x, mini(340, max_w), max_w)
		var target_h = clampi(landscape_size.y, mini(240, max_h), max_h)
		return Vector2i(target_w, target_h)

func _apply_dialog_responsive_styling(dlg: Window) -> void:
	if not dlg:
		return
	dlg.add_theme_stylebox_override("panel", _style_dialog_panel)
	dlg.add_theme_color_override("title_color", Color(0.96, 0.98, 1.0, 1.0))
	var t_size = 30 if is_portrait_mode else 15
	var t_height = 56 if is_portrait_mode else 34
	var close_v = 38 if is_portrait_mode else 22
	var close_h = 28 if is_portrait_mode else 16
	dlg.add_theme_font_size_override("title_font_size", t_size)
	dlg.add_theme_font_size_override("title_size", t_size)
	dlg.add_theme_constant_override("title_height", t_height)
	dlg.add_theme_constant_override("close_v_offset", close_v)
	dlg.add_theme_constant_override("close_h_offset", close_h)
	if ICON_WIN_CLOSE:
		dlg.add_theme_icon_override("close", ICON_WIN_CLOSE)
	if ICON_WIN_CLOSE_HL:
		dlg.add_theme_icon_override("close_pressed", ICON_WIN_CLOSE_HL)
	
	var eb = StyleBoxFlat.new()
	eb.bg_color = Color(0.18, 0.22, 0.30, 1.0)
	eb.set_corner_radius_all(14)
	eb.expand_margin_top = t_height
	eb.expand_margin_bottom = 6
	eb.expand_margin_left = 6
	eb.expand_margin_right = 6
	eb.content_margin_top = t_height - 4
	eb.content_margin_bottom = 8
	eb.content_margin_left = 10
	eb.content_margin_right = 10
	eb.shadow_color = Color(0, 0, 0, 0.22)
	eb.shadow_size = 14
	dlg.add_theme_stylebox_override("embedded_border", eb)
	dlg.add_theme_stylebox_override("embedded_unfocused_border", eb)
	
	if dlg is AcceptDialog:
		var ok_btn = (dlg as AcceptDialog).get_ok_button()
		if ok_btn:
			var ok_sb = StyleBoxFlat.new()
			ok_sb.bg_color = Color(0.145, 0.388, 0.922, 1.0)
			ok_sb.set_corner_radius_all(14)
			ok_sb.shadow_size = 6
			ok_sb.shadow_color = Color(0.145, 0.388, 0.922, 0.35)
			ok_sb.content_margin_left = 52 if is_portrait_mode else 22
			ok_sb.content_margin_right = 52 if is_portrait_mode else 22
			ok_sb.content_margin_top = 16 if is_portrait_mode else 6
			ok_sb.content_margin_bottom = 16 if is_portrait_mode else 6
			ok_btn.add_theme_stylebox_override("normal", ok_sb)
			ok_btn.add_theme_stylebox_override("hover", ok_sb)
			ok_btn.add_theme_stylebox_override("pressed", ok_sb)
			ok_btn.add_theme_stylebox_override("focus", ok_sb)
			ok_btn.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))
			ok_btn.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 1.0, 1.0))
			ok_btn.add_theme_font_size_override("font_size", 24 if is_portrait_mode else 13)
			ok_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	
	if dlg is ConfirmationDialog:
		var cancel_btn = (dlg as ConfirmationDialog).get_cancel_button()
		if cancel_btn:
			var c_sb = StyleBoxFlat.new()
			c_sb.bg_color = Color(0.94, 0.955, 0.975, 1.0)
			c_sb.border_width_left = 1
			c_sb.border_width_top = 1
			c_sb.border_width_right = 1
			c_sb.border_width_bottom = 1
			c_sb.border_color = Color(0.82, 0.85, 0.9, 1.0)
			c_sb.set_corner_radius_all(12)
			c_sb.content_margin_left = 28 if is_portrait_mode else 16
			c_sb.content_margin_right = 28 if is_portrait_mode else 16
			c_sb.content_margin_top = 12 if is_portrait_mode else 6
			c_sb.content_margin_bottom = 12 if is_portrait_mode else 6
			cancel_btn.add_theme_stylebox_override("normal", c_sb)
			cancel_btn.add_theme_stylebox_override("hover", c_sb)
			cancel_btn.add_theme_color_override("font_color", Color(0.12, 0.16, 0.24, 1.0))
			cancel_btn.add_theme_font_size_override("font_size", 20 if is_portrait_mode else 13)
		var ok_btn = (dlg as ConfirmationDialog).get_ok_button()
		if ok_btn:
			var d_sb = StyleBoxFlat.new()
			d_sb.bg_color = Color(0.99, 0.95, 0.95, 1.0)
			d_sb.border_width_left = 1
			d_sb.border_width_top = 1
			d_sb.border_width_right = 1
			d_sb.border_width_bottom = 1
			d_sb.border_color = Color(0.95, 0.65, 0.65, 0.9)
			d_sb.set_corner_radius_all(12)
			d_sb.content_margin_left = 28 if is_portrait_mode else 16
			d_sb.content_margin_right = 28 if is_portrait_mode else 16
			d_sb.content_margin_top = 12 if is_portrait_mode else 6
			d_sb.content_margin_bottom = 12 if is_portrait_mode else 6
			ok_btn.add_theme_stylebox_override("normal", d_sb)
			ok_btn.add_theme_stylebox_override("hover", d_sb)
			ok_btn.add_theme_color_override("font_color", Color(0.85, 0.15, 0.15, 1.0))
			ok_btn.add_theme_font_size_override("font_size", 20 if is_portrait_mode else 13)
		var lbl = (dlg as ConfirmationDialog).get_label()
		if lbl:
			lbl.add_theme_color_override("font_color", Color(0.12, 0.16, 0.24, 1.0))
			lbl.add_theme_font_size_override("font_size", 21 if is_portrait_mode else 13)
			lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

func _update_settings_dialog_controls() -> void:
	var font_sz = 26 if is_portrait_mode else 12
	var header_sz = 28 if is_portrait_mode else 13
	var btn_h = 66 if is_portrait_mode else 34
	var chk_h = 60 if is_portrait_mode else 28
	
	var settings_vbox = settings_dialog.find_child("SettingsVBox", true, false) as BoxContainer
	if settings_vbox:
		settings_vbox.add_theme_constant_override("separation", 16 if is_portrait_mode else 12)
	
	var audio_hdr = settings_dialog.find_child("AudioHeader", true, false) as Label
	if audio_hdr:
		audio_hdr.text = "🔊   AUDIO & LAUTSTÄRKE"
		audio_hdr.add_theme_font_size_override("font_size", header_sz)
		audio_hdr.add_theme_color_override("font_color", Color(0.114, 0.306, 0.847, 1.0))
	
	var view_hdr = settings_dialog.find_child("ViewHeader", true, false) as Label
	if view_hdr:
		view_hdr.text = "🏝️   ANSICHT & KAMERA"
		view_hdr.add_theme_font_size_override("font_size", header_sz)
		view_hdr.add_theme_color_override("font_color", Color(0.114, 0.306, 0.847, 1.0))
	
	var data_hdr = settings_dialog.find_child("DataHeader", true, false) as Label
	if data_hdr:
		data_hdr.text = "💾   SPEICHERSTAND & INSEL"
		data_hdr.add_theme_font_size_override("font_size", header_sz)
		data_hdr.add_theme_color_override("font_color", Color(0.114, 0.306, 0.847, 1.0))
	
	var master_box = settings_dialog.find_child("MasterVolBox", true, false) as BoxContainer
	if master_box:
		master_box.add_theme_constant_override("separation", 8 if is_portrait_mode else 4)
	
	var master_lbl = settings_dialog.find_child("MasterVolLabel", true, false) as Label
	if master_lbl:
		master_lbl.add_theme_font_size_override("font_size", font_sz)
		master_lbl.add_theme_color_override("font_color", Color(0.12, 0.16, 0.24, 1.0))
	
	if slider_master:
		var track_h = 20 if is_portrait_mode else 10
		var track_margin = 8 if is_portrait_mode else 5
		var slider_track_sb = StyleBoxFlat.new()
		slider_track_sb.bg_color = Color(0.88, 0.91, 0.94, 1.0)
		slider_track_sb.set_corner_radius_all(track_h / 2)
		slider_track_sb.content_margin_top = track_margin
		slider_track_sb.content_margin_bottom = track_margin
		
		var slider_fill_sb = StyleBoxFlat.new()
		slider_fill_sb.bg_color = Color(0.145, 0.388, 0.922, 1.0)
		slider_fill_sb.set_corner_radius_all(track_h / 2)
		slider_fill_sb.content_margin_top = track_margin
		slider_fill_sb.content_margin_bottom = track_margin
		
		slider_master.add_theme_stylebox_override("slider", slider_track_sb)
		slider_master.add_theme_stylebox_override("grabber_area", slider_fill_sb)
		slider_master.add_theme_stylebox_override("grabber_area_highlight", slider_fill_sb)
		slider_master.add_theme_icon_override("grabber", ICON_SLIDER_GRABBER)
		slider_master.add_theme_icon_override("grabber_highlight", ICON_SLIDER_GRABBER_HL)
		slider_master.custom_minimum_size = Vector2(0, 58 if is_portrait_mode else 36)
	
	var chk_sep = 18 if is_portrait_mode else 10
	for chk in [check_mute, check_grid_lines, check_night_mode]:
		if chk:
			chk.add_theme_icon_override("checked", ICON_CHECK_CHECKED)
			chk.add_theme_icon_override("unchecked", ICON_CHECK_UNCHECKED)
			chk.add_theme_icon_override("checked_disabled", ICON_CHECK_CHECKED)
			chk.add_theme_icon_override("unchecked_disabled", ICON_CHECK_UNCHECKED)
			chk.add_theme_constant_override("h_separation", chk_sep)
			chk.add_theme_constant_override("check_v_offset", 0)
			chk.custom_minimum_size = Vector2(0, chk_h)
	
	if check_mute:
		check_mute.text = "🔇  Ton stummschalten (Mute)"
		check_mute.add_theme_font_size_override("font_size", font_sz)
		check_mute.add_theme_color_override("font_color", Color(0.12, 0.16, 0.24, 1.0))
		check_mute.add_theme_color_override("font_pressed_color", Color(0.12, 0.16, 0.24, 1.0))
		check_mute.add_theme_color_override("font_hover_color", Color(0.14, 0.38, 0.92, 1.0))
		check_mute.add_theme_color_override("font_hover_pressed_color", Color(0.14, 0.38, 0.92, 1.0))
	
	if check_grid_lines:
		check_grid_lines.text = "📐  3D-Gitterlinien anzeigen"
		check_grid_lines.add_theme_font_size_override("font_size", font_sz)
		check_grid_lines.add_theme_color_override("font_color", Color(0.12, 0.16, 0.24, 1.0))
		check_grid_lines.add_theme_color_override("font_pressed_color", Color(0.12, 0.16, 0.24, 1.0))
		check_grid_lines.add_theme_color_override("font_hover_color", Color(0.14, 0.38, 0.92, 1.0))
		check_grid_lines.add_theme_color_override("font_hover_pressed_color", Color(0.14, 0.38, 0.92, 1.0))
	
	if check_night_mode:
		check_night_mode.text = "🌙  Nachtmodus (Tag/Nacht)"
		check_night_mode.add_theme_font_size_override("font_size", font_sz)
		check_night_mode.add_theme_color_override("font_color", Color(0.12, 0.16, 0.24, 1.0))
		check_night_mode.add_theme_color_override("font_pressed_color", Color(0.12, 0.16, 0.24, 1.0))
		check_night_mode.add_theme_color_override("font_hover_color", Color(0.14, 0.38, 0.92, 1.0))
		check_night_mode.add_theme_color_override("font_hover_pressed_color", Color(0.14, 0.38, 0.92, 1.0))
	
	if btn_reset_cam_settings:
		btn_reset_cam_settings.text = "🎥   Kamera-Ansicht zentrieren"
		btn_reset_cam_settings.add_theme_stylebox_override("normal", _style_dialog_btn)
		btn_reset_cam_settings.add_theme_stylebox_override("hover", _style_dialog_btn_hover)
		btn_reset_cam_settings.add_theme_stylebox_override("pressed", _style_dialog_btn_hover)
		btn_reset_cam_settings.add_theme_color_override("font_color", Color(0.12, 0.16, 0.24, 1.0))
		btn_reset_cam_settings.add_theme_color_override("font_hover_color", Color(0.14, 0.38, 0.92, 1.0))
		btn_reset_cam_settings.add_theme_font_size_override("font_size", font_sz)
		btn_reset_cam_settings.custom_minimum_size = Vector2(0, btn_h)
	
	var saveload_box = settings_dialog.find_child("SaveLoadHBox", true, false) as BoxContainer
	if saveload_box:
		saveload_box.add_theme_constant_override("separation", 14 if is_portrait_mode else 8)
	
	if btn_save_settings:
		btn_save_settings.text = "💾   Speichern"
		btn_save_settings.add_theme_stylebox_override("normal", _style_dialog_btn)
		btn_save_settings.add_theme_stylebox_override("hover", _style_dialog_btn_hover)
		btn_save_settings.add_theme_stylebox_override("pressed", _style_dialog_btn_hover)
		btn_save_settings.add_theme_color_override("font_color", Color(0.12, 0.16, 0.24, 1.0))
		btn_save_settings.add_theme_color_override("font_hover_color", Color(0.14, 0.38, 0.92, 1.0))
		btn_save_settings.add_theme_font_size_override("font_size", font_sz)
		btn_save_settings.custom_minimum_size = Vector2(0, btn_h)
	
	if btn_load_settings:
		btn_load_settings.text = "📂   Laden"
		btn_load_settings.add_theme_stylebox_override("normal", _style_dialog_btn)
		btn_load_settings.add_theme_stylebox_override("hover", _style_dialog_btn_hover)
		btn_load_settings.add_theme_stylebox_override("pressed", _style_dialog_btn_hover)
		btn_load_settings.add_theme_color_override("font_color", Color(0.12, 0.16, 0.24, 1.0))
		btn_load_settings.add_theme_color_override("font_hover_color", Color(0.14, 0.38, 0.92, 1.0))
		btn_load_settings.add_theme_font_size_override("font_size", font_sz)
		btn_load_settings.custom_minimum_size = Vector2(0, btn_h)
	
	if btn_open_screenshots:
		btn_open_screenshots.text = "📁   Screenshots-Ordner öffnen"
		btn_open_screenshots.add_theme_stylebox_override("normal", _style_dialog_btn)
		btn_open_screenshots.add_theme_stylebox_override("hover", _style_dialog_btn_hover)
		btn_open_screenshots.add_theme_stylebox_override("pressed", _style_dialog_btn_hover)
		btn_open_screenshots.add_theme_color_override("font_color", Color(0.12, 0.16, 0.24, 1.0))
		btn_open_screenshots.add_theme_color_override("font_hover_color", Color(0.14, 0.38, 0.92, 1.0))
		btn_open_screenshots.add_theme_font_size_override("font_size", font_sz)
		btn_open_screenshots.custom_minimum_size = Vector2(0, btn_h)
		btn_open_screenshots.visible = not OS.has_feature("mobile")
	
	if btn_reset_island_settings:
		btn_reset_island_settings.text = "🔄   Insel auf Starter-Stand zurücksetzen"
		btn_reset_island_settings.add_theme_stylebox_override("normal", _style_dialog_btn_danger)
		btn_reset_island_settings.add_theme_stylebox_override("hover", _style_dialog_btn_danger)
		btn_reset_island_settings.add_theme_stylebox_override("pressed", _style_dialog_btn_danger)
		btn_reset_island_settings.add_theme_color_override("font_color", Color(0.85, 0.15, 0.15, 1.0))
		btn_reset_island_settings.add_theme_color_override("font_hover_color", Color(0.7, 0.1, 0.1, 1.0))
		btn_reset_island_settings.add_theme_font_size_override("font_size", font_sz)
		btn_reset_island_settings.custom_minimum_size = Vector2(0, btn_h)

func _update_credits_dialog_content() -> void:
	if not credits_text:
		return
	credits_text.add_theme_color_override("default_color", Color(0.12, 0.16, 0.24, 1.0))
	var font_sz = 26 if is_portrait_mode else 13
	var title_sz = 34 if is_portrait_mode else 16
	var sub_sz = 20 if is_portrait_mode else 11
	var icon_sz = 30 if is_portrait_mode else 16
	credits_text.add_theme_font_size_override("normal_font_size", font_sz)
	credits_text.add_theme_font_size_override("bold_font_size", font_sz + 2)
	credits_text.add_theme_font_size_override("italics_font_size", font_sz)
	credits_text.add_theme_constant_override("line_separation", 8 if is_portrait_mode else 2)
	var ver = AppVersion.VERSION if ClassDB.class_exists(&"AppVersion") or "AppVersion" in get_tree().root else "0.1.0-beta.1"
	if not ver.begins_with("v"):
		ver = "v" + ver
	credits_text.text = "[center][b][font_size=%d]🏝️   Diorama Sandbox[/font_size][/b]\n[font_size=%d][color=#2563eb]Native Edition %s • Cross-Platform (Linux / Windows / Android)[/color][/font_size][/center]\n\n[font_size=%d][img=%d]res://assets/icons/team.svg[/img]  [b]Team & Entwicklung:[/b]\n• [b]Jennifer Graßl:[/b] Architektur & Software-Entwicklung\n• [b]Sara Graßl:[/b] Ideen, Content-Beiträge & Playtesting\n• [b]Gemini:[/b] Konzept & KI-Entwicklungspartner\n\n[img=%d]res://assets/icons/license.svg[/img]  [b]Third-Party Credits & Lizenzen:[/b]\n• [b]Engine:[/b] Godot Engine 4 (MIT Lizenz)\n• [b]SFX & Audio:[/b] Kenney (CC0) & Wikimedia Commons (CC0)\n• [b]Design:[/b] Zero-Asset Low-Poly Modulsystem[/font_size]" % [title_sz, sub_sz, ver, font_sz, icon_sz, icon_sz]

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
	
	_apply_dialog_responsive_styling(settings_dialog)
	_update_settings_dialog_controls()
	var dsize = _get_responsive_dialog_size(Vector2i(540, 500), Vector2i(900, 800))
	var margin = settings_dialog.find_child("SettingsMargin") as Control
	if margin:
		margin.custom_minimum_size = Vector2(dsize.x - 32, dsize.y - 90)
	settings_dialog.reset_size()
	settings_dialog.popup_centered(dsize)

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

func _get_save_file_dialog() -> FileDialog:
	if not _save_file_dialog:
		_save_file_dialog = FileDialog.new()
		_save_file_dialog.title = "Diorama-Foto speichern"
		_save_file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
		_save_file_dialog.access = FileDialog.ACCESS_FILESYSTEM
		_save_file_dialog.use_native_dialog = true
		_save_file_dialog.filters = PackedStringArray(["*.png ; PNG-Bilder (*.png)"])
		_save_file_dialog.file_selected.connect(_on_snapshot_file_selected)
		_save_file_dialog.canceled.connect(_on_snapshot_canceled)
		add_child(_save_file_dialog)
	return _save_file_dialog

func _on_snapshot_file_selected(path: String) -> void:
	if not _pending_snapshot_image:
		return
	var err = _pending_snapshot_image.save_png(path)
	if err == OK:
		show_toast("📸 Foto gespeichert: %s ✓" % path.get_file())
	else:
		show_toast("⚠️ Fehler beim Speichern des Fotos")
	_pending_snapshot_image = null

func _on_snapshot_canceled() -> void:
	_pending_snapshot_image = null

func _on_open_screenshots_pressed() -> void:
	var sc_dir = ProjectSettings.globalize_path("user://screenshots")
	if not DirAccess.dir_exists_absolute(sc_dir):
		DirAccess.make_dir_absolute(sc_dir)
	OS.shell_open(sc_dir)
	show_toast("📁 Screenshot-Ordner geöffnet")

func _on_snapshot_pressed() -> void:
	# 1. Capture pristine viewport image first
	var img = get_viewport().get_texture().get_image()
	if not img:
		show_toast("⚠️ Konnte Bild nicht aufnehmen")
		return
	
	_pending_snapshot_image = img
	
	# 2. Camera click sound & visual flash effect
	AudioManager.play("click")
	if flash_rect:
		flash_rect.color.a = 0.85
		var tween = create_tween()
		tween.tween_property(flash_rect, "color:a", 0.0, 0.35)
	
	var ts = Time.get_datetime_string_from_system().replace(":", "-")
	var default_filename = "diorama_%s.png" % ts
	
	# 3. Always keep a safety copy in user://screenshots
	var dir_path = "user://screenshots"
	DirAccess.make_dir_absolute(dir_path)
	var backup_path = "%s/%s" % [dir_path, default_filename]
	img.save_png(backup_path)
	
	# 4. On Desktop: open Save File Dialog so user can pick folder & name
	if not OS.has_feature("mobile"):
		var fd = _get_save_file_dialog()
		var pic_dir = OS.get_system_dir(OS.SYSTEM_DIR_PICTURES)
		if pic_dir.is_empty() or not DirAccess.dir_exists_absolute(pic_dir):
			pic_dir = OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP)
		if pic_dir.is_empty() or not DirAccess.dir_exists_absolute(pic_dir):
			pic_dir = ProjectSettings.globalize_path("user://screenshots")
		
		fd.current_dir = pic_dir
		fd.current_file = default_filename
		fd.popup_centered(Vector2i(800, 520))
		show_toast("📸 Foto aufgenommen! Speicherort wählen...")
	else:
		show_toast("📸 Foto in Screenshots gespeichert! ✓")
		_pending_snapshot_image = null

func _on_reset_pressed() -> void:
	if settings_dialog:
		settings_dialog.hide()
	_apply_dialog_responsive_styling(reset_confirm_dialog)
	var dsize = _get_responsive_dialog_size(Vector2i(480, 240), Vector2i(850, 320))
	var rlabel = reset_confirm_dialog.get_label()
	if rlabel:
		rlabel.custom_minimum_size = Vector2(dsize.x - 48, 0)
	reset_confirm_dialog.reset_size()
	reset_confirm_dialog.popup_centered(dsize)

func _on_reset_confirmed() -> void:
	if reset_confirm_dialog:
		reset_confirm_dialog.hide()
	reset_island_requested.emit()
	show_toast("🔄 Diorama auf Starter-Insel zurückgesetzt ✓")

func _on_reset_canceled() -> void:
	if reset_confirm_dialog:
		reset_confirm_dialog.hide()
	if settings_dialog:
		_apply_dialog_responsive_styling(settings_dialog)
		_update_settings_dialog_controls()
		var dsize = _get_responsive_dialog_size(Vector2i(540, 500), Vector2i(900, 800))
		var margin = settings_dialog.find_child("SettingsMargin") as Control
		if margin:
			margin.custom_minimum_size = Vector2(dsize.x - 32, dsize.y - 90)
		settings_dialog.reset_size()
		settings_dialog.popup_centered(dsize)

func _on_info_pressed() -> void:
	_apply_dialog_responsive_styling(credits_dialog)
	_update_credits_dialog_content()
	var dsize = _get_responsive_dialog_size(Vector2i(560, 420), Vector2i(900, 680))
	var cmargin = credits_dialog.find_child("CreditsMargin") as Control
	if cmargin:
		cmargin.custom_minimum_size = Vector2(dsize.x - 32, dsize.y - 90)
	credits_dialog.reset_size()
	credits_dialog.popup_centered(dsize)

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

func _refresh_catalog_cards_layout() -> void:
	if not catalog_grid:
		return
	var card_sz = Vector2(160, 130) if is_portrait_mode else Vector2(100, 80)
	var font_sz = 26 if is_portrait_mode else 12
	var line_spacing = 8 if is_portrait_mode else 4
	for child in catalog_grid.get_children():
		if child is Button:
			child.custom_minimum_size = card_sz
			child.add_theme_font_size_override("font_size", font_sz)
			child.add_theme_constant_override("line_spacing", line_spacing)

# -----------------------------------------------------------------------------
# Responsive Layout & Safe Area
# -----------------------------------------------------------------------------
var _is_updating_layout: bool = false
var _last_layout_size: Vector2i = Vector2i.ZERO
var _is_layout_deferred_pending: bool = false

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_SIZE_CHANGED:
		_on_viewport_size_changed()

func _on_viewport_size_changed() -> void:
	if not is_inside_tree():
		return
	if not _is_layout_deferred_pending:
		_is_layout_deferred_pending = true
		_apply_layout_deferred.call_deferred()

func _apply_layout_deferred() -> void:
	_is_layout_deferred_pending = false
	if not is_inside_tree() or _is_updating_layout:
		return
	var vp = get_viewport()
	var vp_size: Vector2i = Vector2i.ZERO
	if vp:
		vp_size = vp.size
	if vp_size.x <= 0 or vp_size.y <= 0:
		vp_size = DisplayServer.window_get_size()
	if vp_size.x <= 0 or vp_size.y <= 0:
		return
	if vp_size == _last_layout_size:
		return
	
	_is_updating_layout = true
	_last_layout_size = vp_size
	
	var is_portrait: bool = (vp_size.y > vp_size.x)
	var prev_portrait: bool = is_portrait_mode
	is_portrait_mode = is_portrait
	
	# If orientation changed, swiftly update card dimensions without recreating nodes
	if prev_portrait != is_portrait:
		_refresh_catalog_cards_layout()
	
	_apply_safe_area_and_layout(vp_size, Vector2(vp_size), is_portrait)
	_is_updating_layout = false

func _apply_safe_area_and_layout(win_size: Vector2i, vp_size: Vector2, is_portrait: bool) -> void:
	var top_inset: float = 0.0
	var bottom_inset: float = 0.0
	var left_inset: float = 0.0
	var right_inset: float = 0.0
	
	# Safe area insets (notches, punch-holes, gesture bars) ONLY apply on mobile platforms.
	# On desktop (Linux/X11/Wayland/Windows), get_display_safe_area() returns multi-monitor coordinates which must NOT be used as insets.
	if OS.has_feature("mobile"):
		var safe_area: Rect2i = DisplayServer.get_display_safe_area()
		if safe_area.size.x > 0 and safe_area.size.y > 0 and win_size.x > 0 and win_size.y > 0:
			var sx = vp_size.x / float(win_size.x)
			var sy = vp_size.y / float(win_size.y)
			if safe_area.position.y > 0:
				top_inset = max(0.0, float(safe_area.position.y) * sy)
			if safe_area.position.x > 0:
				left_inset = max(0.0, float(safe_area.position.x) * sx)
			var diff_right = float(win_size.x - (safe_area.position.x + safe_area.size.x))
			if diff_right > 0:
				right_inset = max(0.0, diff_right * sx)
			var diff_bottom = float(win_size.y - (safe_area.position.y + safe_area.size.y))
			if diff_bottom > 0:
				bottom_inset = max(0.0, diff_bottom * sy)
	
	if top_bar:
		if is_portrait:
			top_bar.custom_minimum_size = Vector2(0, 96)
			top_bar.offset_top = 10.0 + top_inset
			top_bar.offset_bottom = 106.0 + top_inset
			top_bar.offset_left = 10.0 + left_inset
			top_bar.offset_right = -(10.0 + right_inset)
		else:
			top_bar.custom_minimum_size = Vector2(0, 42)
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
	
	# Brand label & status in landscape
	var brand_title = get_node_or_null("%BrandPill/BrandMargin/BrandHBox/BrandTitle") as Label
	if brand_title:
		brand_title.text = "🏝️ Diorama-Sandbox"
		brand_title.add_theme_font_size_override("font_size", 13)
	if status_label:
		status_label.visible = true
		status_label.add_theme_font_size_override("font_size", 11)
	
	# Grid size buttons in landscape
	for grid_btn in [btn_grid_8, btn_grid_12, btn_grid_16, btn_grid_20, btn_grid_24]:
		if grid_btn:
			grid_btn.custom_minimum_size = Vector2(50, 28)
			grid_btn.add_theme_font_size_override("font_size", 12)
	
	# Full button text in landscape with crisp vector icons
	if btn_snapshot:
		btn_snapshot.icon = ICON_CAMERA
		btn_snapshot.expand_icon = true
		btn_snapshot.text = "Foto"
		btn_snapshot.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn_snapshot.vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER
		btn_snapshot.custom_minimum_size = Vector2(86, 32)
		btn_snapshot.add_theme_font_size_override("font_size", 13)
		btn_snapshot.add_theme_constant_override("icon_max_width", 18)
		btn_snapshot.add_theme_constant_override("h_separation", 8)
	if btn_info:
		btn_info.icon = ICON_INFO
		btn_info.expand_icon = true
		btn_info.text = "Info"
		btn_info.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn_info.vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER
		btn_info.custom_minimum_size = Vector2(82, 32)
		btn_info.add_theme_font_size_override("font_size", 13)
		btn_info.add_theme_constant_override("icon_max_width", 18)
		btn_info.add_theme_constant_override("h_separation", 8)
	if btn_settings:
		btn_settings.icon = ICON_SETTINGS
		btn_settings.expand_icon = true
		btn_settings.text = "Optionen"
		btn_settings.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn_settings.vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER
		btn_settings.custom_minimum_size = Vector2(108, 32)
		btn_settings.add_theme_font_size_override("font_size", 13)
		btn_settings.add_theme_constant_override("icon_max_width", 18)
		btn_settings.add_theme_constant_override("h_separation", 8)
	
	# Show sidebar labels & separators
	if tools_label: tools_label.visible = true
	if cat_section_label: cat_section_label.visible = true
	if h_separator_1: h_separator_1.visible = true
	if h_separator_2: h_separator_2.visible = true
	if category_title_label: category_title_label.visible = true
	
	# Tool buttons in landscape
	if btn_tool_explore:
		btn_tool_explore.custom_minimum_size = Vector2(0, 34)
		btn_tool_explore.add_theme_font_size_override("font_size", 12)
	for t_btn in [btn_tool_select, btn_tool_place, btn_tool_rotate, btn_tool_demolish]:
		if t_btn:
			t_btn.custom_minimum_size = Vector2(0, 32)
			t_btn.add_theme_font_size_override("font_size", 12)
	if btn_undo:
		btn_undo.custom_minimum_size = Vector2(0, 28)
		btn_undo.add_theme_font_size_override("font_size", 12)
	if btn_redo:
		btn_redo.custom_minimum_size = Vector2(0, 28)
		btn_redo.add_theme_font_size_override("font_size", 12)
	for c_btn in [cat_ground_btn, cat_buildings_btn, cat_nature_btn, cat_creatures_btn, cat_deco_btn]:
		if c_btn:
			c_btn.custom_minimum_size = Vector2(0, 32)
			c_btn.add_theme_font_size_override("font_size", 13)
	
	# 2 columns in landscape sidebar
	if tools_grid:
		tools_grid.columns = 2
	if catalog_grid:
		catalog_grid.columns = 2
	if scroll_container:
		scroll_container.custom_minimum_size = Vector2(0, 240)
	
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
	btn_toggle_sidebar.add_theme_font_size_override("font_size", 12)

func _apply_portrait_layout(left_inset: float, right_inset: float, bottom_inset: float) -> void:
	if not sidebar_wrapper or not btn_toggle_sidebar:
		return
	
	if sidebar_panel:
		sidebar_panel.add_theme_stylebox_override("panel", _style_sidebar_portrait)
	
	# Brand label in portrait (clean & readable)
	var brand_title = get_node_or_null("%BrandPill/BrandMargin/BrandHBox/BrandTitle") as Label
	if brand_title:
		brand_title.text = "🏝️ Diorama"
		brand_title.add_theme_font_size_override("font_size", 26)
	if status_label:
		status_label.visible = false
	
	# Grid size buttons in portrait - enlarged for easy finger taps
	for grid_btn in [btn_grid_8, btn_grid_12, btn_grid_16, btn_grid_20, btn_grid_24]:
		if grid_btn:
			grid_btn.custom_minimum_size = Vector2(96, 72)
			grid_btn.add_theme_font_size_override("font_size", 22)
	
	# Compact TopBar action buttons: massive thumb targets with large clear vector icons
	if btn_snapshot:
		btn_snapshot.icon = ICON_CAMERA
		btn_snapshot.expand_icon = true
		btn_snapshot.text = ""
		btn_snapshot.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		btn_snapshot.vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER
		btn_snapshot.custom_minimum_size = Vector2(92, 76)
		btn_snapshot.add_theme_constant_override("icon_max_width", 44)
	if btn_info:
		btn_info.icon = ICON_INFO
		btn_info.expand_icon = true
		btn_info.text = ""
		btn_info.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		btn_info.vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER
		btn_info.custom_minimum_size = Vector2(92, 76)
		btn_info.add_theme_constant_override("icon_max_width", 44)
	if btn_settings:
		btn_settings.icon = ICON_SETTINGS
		btn_settings.expand_icon = true
		btn_settings.text = ""
		btn_settings.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		btn_settings.vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER
		btn_settings.custom_minimum_size = Vector2(92, 76)
		btn_settings.add_theme_constant_override("icon_max_width", 44)
	
	# Hide decorative labels & separators in compact bottom dock
	if tools_label: tools_label.visible = false
	if cat_section_label: cat_section_label.visible = false
	if h_separator_1: h_separator_1.visible = false
	if h_separator_2: h_separator_2.visible = false
	if category_title_label: category_title_label.visible = false
	
	# Bottom dock tools and controls styling with large readable fonts and icons
	if btn_tool_explore:
		btn_tool_explore.custom_minimum_size = Vector2(0, 68)
		btn_tool_explore.add_theme_font_size_override("font_size", 26)
	for t_btn in [btn_tool_select, btn_tool_place, btn_tool_rotate, btn_tool_demolish]:
		if t_btn:
			t_btn.custom_minimum_size = Vector2(0, 72)
			t_btn.add_theme_font_size_override("font_size", 26)
	if btn_undo:
		btn_undo.custom_minimum_size = Vector2(0, 56)
		btn_undo.add_theme_font_size_override("font_size", 30)
	if btn_redo:
		btn_redo.custom_minimum_size = Vector2(0, 56)
		btn_redo.add_theme_font_size_override("font_size", 30)
	for c_btn in [cat_ground_btn, cat_buildings_btn, cat_nature_btn, cat_creatures_btn, cat_deco_btn]:
		if c_btn:
			c_btn.custom_minimum_size = Vector2(0, 76)
			c_btn.add_theme_font_size_override("font_size", 42)
	
	# 4 columns for tools and catalog in bottom dock
	if tools_grid:
		tools_grid.columns = 4
	if catalog_grid:
		catalog_grid.columns = 4
	if scroll_container:
		scroll_container.custom_minimum_size = Vector2(0, 310)
	
	sidebar_wrapper.anchor_left = 0.0
	sidebar_wrapper.anchor_top = 1.0
	sidebar_wrapper.anchor_right = 1.0
	sidebar_wrapper.anchor_bottom = 1.0
	
	var dock_height = 700.0
	sidebar_wrapper.offset_left = 10.0 + left_inset
	sidebar_wrapper.offset_right = -(10.0 + right_inset)
	sidebar_wrapper.offset_top = -(dock_height + bottom_inset) if is_sidebar_open else 0.0
	sidebar_wrapper.offset_bottom = -bottom_inset if is_sidebar_open else (dock_height + bottom_inset)
	
	btn_toggle_sidebar.anchor_left = 0.5
	btn_toggle_sidebar.anchor_top = 0.0
	btn_toggle_sidebar.anchor_right = 0.5
	btn_toggle_sidebar.anchor_bottom = 0.0
	btn_toggle_sidebar.offset_left = -140.0
	btn_toggle_sidebar.offset_right = 140.0
	btn_toggle_sidebar.offset_top = -60.0
	btn_toggle_sidebar.offset_bottom = 0.0
	btn_toggle_sidebar.text = "▼ Schließen" if is_sidebar_open else "▲ Werkzeuge"
	btn_toggle_sidebar.add_theme_font_size_override("font_size", 24)
	btn_toggle_sidebar.add_theme_color_override("font_color", Color(0.06, 0.09, 0.16, 1.0))
	btn_toggle_sidebar.add_theme_color_override("font_hover_color", Color(0.14, 0.38, 0.92, 1.0))
	btn_toggle_sidebar.add_theme_color_override("font_pressed_color", Color(0.14, 0.38, 0.92, 1.0))
	
	# If any dialog is currently visible, update styling and resize to current orientation
	if settings_dialog and settings_dialog.visible:
		_apply_dialog_responsive_styling(settings_dialog)
		_update_settings_dialog_controls()
		var dsize = _get_responsive_dialog_size(Vector2i(540, 500), Vector2i(900, 800))
		var margin = settings_dialog.find_child("SettingsMargin") as Control
		if margin:
			margin.custom_minimum_size = Vector2(dsize.x - 32, dsize.y - 90)
		settings_dialog.reset_size()
		settings_dialog.popup_centered(dsize)
	if credits_dialog and credits_dialog.visible:
		_apply_dialog_responsive_styling(credits_dialog)
		_update_credits_dialog_content()
		var dsize = _get_responsive_dialog_size(Vector2i(560, 420), Vector2i(900, 640))
		var cmargin = credits_dialog.find_child("CreditsMargin") as Control
		if cmargin:
			cmargin.custom_minimum_size = Vector2(dsize.x - 32, dsize.y - 90)
		credits_dialog.reset_size()
		credits_dialog.popup_centered(dsize)
	if reset_confirm_dialog and reset_confirm_dialog.visible:
		_apply_dialog_responsive_styling(reset_confirm_dialog)
		var dsize = _get_responsive_dialog_size(Vector2i(480, 240), Vector2i(850, 320))
		var rlabel = reset_confirm_dialog.get_label()
		if rlabel:
			rlabel.custom_minimum_size = Vector2(dsize.x - 48, 0)
		reset_confirm_dialog.reset_size()
		reset_confirm_dialog.popup_centered(dsize)

func _toggle_sidebar() -> void:
	is_sidebar_open = not is_sidebar_open
	var tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	if is_portrait_mode:
		var dock_height = 700.0
		var target_top = -dock_height if is_sidebar_open else 0.0
		var target_bottom = 0.0 if is_sidebar_open else dock_height
		tween.tween_property(sidebar_wrapper, "offset_top", target_top, 0.22)
		tween.tween_property(sidebar_wrapper, "offset_bottom", target_bottom, 0.22)
		btn_toggle_sidebar.text = "▼ Schließen" if is_sidebar_open else "▲ Werkzeuge"
	else:
		var target_left = -SIDEBAR_WIDTH if is_sidebar_open else 0.0
		var target_right = 0.0 if is_sidebar_open else SIDEBAR_WIDTH
		tween.tween_property(sidebar_wrapper, "offset_left", target_left, 0.22)
		tween.tween_property(sidebar_wrapper, "offset_right", target_right, 0.22)
		btn_toggle_sidebar.text = "▶" if is_sidebar_open else "◀"
