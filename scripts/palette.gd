class_name Palette
extends RefCounted

## Global color palette and material generator matching the Modulon Diorama web system

const COLORS = {
	"grass": Color("#48bb78"),
	"grassBright": Color("#68d391"),
	"grassDark": Color("#276749"),
	"dirt": Color("#8b5a2b"),
	"dirtDark": Color("#5c3a1d"),
	"stone": Color("#9ca3af"),
	"stoneDark": Color("#6b7280"),
	"stoneLight": Color("#d1d5db"),
	"wood": Color("#b48455"),
	"woodDark": Color("#8a5d3b"),
	"woodLight": Color("#d4a373"),
	"water": Color("#0284c7"),
	"waterDark": Color("#0369a1"),
	"waterLight": Color("#38bdf8"),
	"waterFoam": Color("#ffffff"),
	"wallPlaster": Color("#fbf8ee"),
	"wallWood": Color("#784a2d"),
	"roofRed": Color("#c2410c"),
	"roofTrim": Color("#9a3412"),
	"chimney": Color("#78716c"),
	"windowGlass": Color("#fef08a"),
	"ironDark": Color("#1f2937"),
	"goldGlow": Color("#ffedd5"),
	"pineGreen": Color("#2d6a4f"),
	"pineGreenLight": Color("#40916c"),
	"leafGreen": Color("#40916c"),
	"leafGreenLight": Color("#52b788"),
	"trunkBrown": Color("#6f4e37"),
	"flowerPot": Color("#d97706"),
	"cactusGreen": Color("#2b9348"),
	"catOrange": Color("#f97316"),
	"catWhite": Color("#ffffff"),
	"catPink": Color("#f472b6"),
	"catEyes": Color("#15803d"),
	"dayBg": Color("#cde7ff"),
	"nightBg": Color("#0e1628"),
	"dayAmbient": Color("#dbeafe"),
	"nightAmbient": Color("#1e293b"),
	"daySun": Color("#fff8ee"),
	"nightSun": Color("#3b82f6"),
}

static var _material_cache: Dictionary = {}

static func get_color(key: String, default_color: Color = Color.WHITE) -> Color:
	return COLORS.get(key, default_color)

static func create_material(color: Color, roughness: float = 0.8, metalness: float = 0.1, emission: Color = Color.BLACK) -> StandardMaterial3D:
	var cache_key = "%s_%.2f_%.2f_%s" % [color.to_html(), roughness, metalness, emission.to_html()]
	if _material_cache.has(cache_key):
		return _material_cache[cache_key]
	
	var mat = StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = roughness
	mat.metallic = metalness
	mat.diffuse_mode = BaseMaterial3D.DIFFUSE_LAMBERT
	mat.specular_mode = BaseMaterial3D.SPECULAR_SCHLICK_GGX
	
	if emission != Color.BLACK:
		mat.emission_enabled = true
		mat.emission = emission
		mat.emission_energy_multiplier = 1.2
	
	_material_cache[cache_key] = mat
	return mat

static func get_palette_material(key: String, roughness: float = 0.8, metalness: float = 0.1, emission_key: String = "") -> StandardMaterial3D:
	var color = get_color(key)
	var emission = Color.BLACK if emission_key.is_empty() else get_color(emission_key)
	return create_material(color, roughness, metalness, emission)
