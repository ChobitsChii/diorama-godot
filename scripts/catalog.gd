class_name Catalog
extends RefCounted

## Catalog registry containing all placeable diorama objects, categories, sizes, and scene paths.

const ITEMS = {
	# Ground Tiles
	"grass": {
		"id": "grass",
		"name": "Rasen",
		"category": "ground",
		"icon": "🌱",
		"size": 1,
		"is_ground": true,
		"scene": "res://scenes/catalog/ground/tile_grass.tscn",
	},
	"stone": {
		"id": "stone",
		"name": "Pflasterstein",
		"category": "ground",
		"icon": "🧱",
		"size": 1,
		"is_ground": true,
		"scene": "res://scenes/catalog/ground/tile_stone.tscn",
	},
	"wood": {
		"id": "wood",
		"name": "Holzterrasse",
		"category": "ground",
		"icon": "🪵",
		"size": 1,
		"is_ground": true,
		"scene": "res://scenes/catalog/ground/tile_wood.tscn",
	},
	"water": {
		"id": "water",
		"name": "Wasser",
		"category": "ground",
		"icon": "💧",
		"size": 1,
		"is_ground": true,
		"scene": "res://scenes/catalog/ground/tile_water.tscn",
	},
	
	# Buildings
	"cottage": {
		"id": "cottage",
		"name": "Gemütliches Haus",
		"category": "buildings",
		"icon": "🏡",
		"size": 2,
		"is_ground": false,
		"scene": "res://scenes/catalog/buildings/cottage.tscn",
	},
	"townhouse": {
		"id": "townhouse",
		"name": "Stadthaus",
		"category": "buildings",
		"icon": "🏘️",
		"size": 1,
		"is_ground": false,
		"scene": "res://scenes/catalog/buildings/townhouse.tscn",
	},
	"apartment": {
		"id": "apartment",
		"name": "Wohnblock",
		"category": "buildings",
		"icon": "🏢",
		"size": 2,
		"is_ground": false,
		"scene": "res://scenes/catalog/buildings/apartment.tscn",
	},
	"logcabin": {
		"id": "logcabin",
		"name": "Blockhütte",
		"category": "buildings",
		"icon": "🪵",
		"size": 2,
		"is_ground": false,
		"scene": "res://scenes/catalog/buildings/logcabin.tscn",
	},
	"bench": {
		"id": "bench",
		"name": "Gartenbank",
		"category": "buildings",
		"icon": "🪑",
		"size": 1,
		"is_ground": false,
		"scene": "res://scenes/catalog/buildings/bench.tscn",
	},
	"picnictable": {
		"id": "picnictable",
		"name": "Picknicktisch",
		"category": "buildings",
		"icon": "🧺",
		"size": 1,
		"is_ground": false,
		"scene": "res://scenes/catalog/buildings/picnictable.tscn",
	},
	"beertable": {
		"id": "beertable",
		"name": "Biertischgarnitur",
		"category": "buildings",
		"icon": "🍻",
		"size": 1,
		"is_ground": false,
		"scene": "res://scenes/catalog/buildings/beertable.tscn",
	},
	"fountain": {
		"id": "fountain",
		"name": "Brunnen",
		"category": "buildings",
		"icon": "⛲",
		"size": 2,
		"is_ground": false,
		"scene": "res://scenes/catalog/buildings/fountain.tscn",
	},
	
	# Nature
	"pine": {
		"id": "pine",
		"name": "Tannenbaum",
		"category": "nature",
		"icon": "🌲",
		"size": 1,
		"is_ground": false,
		"scene": "res://scenes/catalog/nature/pine_tree.tscn",
	},
	"tree": {
		"id": "tree",
		"name": "Laubbaum",
		"category": "nature",
		"icon": "🌳",
		"size": 1,
		"is_ground": false,
		"scene": "res://scenes/catalog/nature/leafy_tree.tscn",
	},
	"flowerbed": {
		"id": "flowerbed",
		"name": "Blumenbeet",
		"category": "nature",
		"icon": "🌷",
		"size": 1,
		"is_ground": false,
		"scene": "res://scenes/catalog/nature/flowerbed.tscn",
	},
	"cactus": {
		"id": "cactus",
		"name": "Kaktus",
		"category": "nature",
		"icon": "🌵",
		"size": 1,
		"is_ground": false,
		"scene": "res://scenes/catalog/nature/cactus.tscn",
	},
	"mushrooms": {
		"id": "mushrooms",
		"name": "Fliegenpilze",
		"category": "nature",
		"icon": "🍄",
		"size": 1,
		"is_ground": false,
		"scene": "res://scenes/catalog/nature/mushrooms.tscn",
	},
	"pond": {
		"id": "pond",
		"name": "Teich mit Seerosen",
		"category": "nature",
		"icon": "🪷",
		"size": 2,
		"is_ground": false,
		"scene": "res://scenes/catalog/nature/pond.tscn",
	},
	
	# Living Creatures
	"cat": {
		"id": "cat",
		"name": "Katze",
		"category": "creatures",
		"icon": "🐱",
		"size": 1,
		"is_ground": false,
		"scene": "res://scenes/catalog/creatures/cat.tscn",
	},
	"dog": {
		"id": "dog",
		"name": "Hund",
		"category": "creatures",
		"icon": "🐶",
		"size": 1,
		"is_ground": false,
		"scene": "res://scenes/catalog/creatures/dog.tscn",
	},
	"duck": {
		"id": "duck",
		"name": "Ente",
		"category": "creatures",
		"icon": "🦆",
		"size": 1,
		"is_ground": false,
		"scene": "res://scenes/catalog/creatures/duck.tscn",
	},
	"rabbit": {
		"id": "rabbit",
		"name": "Häschen",
		"category": "creatures",
		"icon": "🐰",
		"size": 1,
		"is_ground": false,
		"scene": "res://scenes/catalog/creatures/rabbit.tscn",
	},
	"boy": {
		"id": "boy",
		"name": "Junge",
		"category": "creatures",
		"icon": "👦",
		"size": 1,
		"is_ground": false,
		"scene": "res://scenes/catalog/creatures/boy.tscn",
	},
	"girl": {
		"id": "girl",
		"name": "Mädchen",
		"category": "creatures",
		"icon": "👧",
		"size": 1,
		"is_ground": false,
		"scene": "res://scenes/catalog/creatures/girl.tscn",
	},
	
	# Lighting & Deco
	"streetlamp": {
		"id": "streetlamp",
		"name": "Straßenlaterne",
		"category": "deco",
		"icon": "💡",
		"size": 1,
		"is_ground": false,
		"scene": "res://scenes/catalog/deco/streetlamp.tscn",
	},
	"fence": {
		"id": "fence",
		"name": "Holzzaun",
		"category": "deco",
		"icon": "🪵",
		"size": 1,
		"is_ground": false,
		"scene": "res://scenes/catalog/deco/fence.tscn",
	},
	"campfire": {
		"id": "campfire",
		"name": "Lagerfeuer",
		"category": "deco",
		"icon": "🔥",
		"size": 1,
		"is_ground": false,
		"scene": "res://scenes/catalog/deco/campfire.tscn",
	},
	"mailbox": {
		"id": "mailbox",
		"name": "Briefkasten",
		"category": "deco",
		"icon": "📫",
		"size": 1,
		"is_ground": false,
		"scene": "res://scenes/catalog/deco/mailbox.tscn",
	},
	"signpost": {
		"id": "signpost",
		"name": "Wegweiser",
		"category": "deco",
		"icon": "🪧",
		"size": 1,
		"is_ground": false,
		"scene": "res://scenes/catalog/deco/signpost.tscn",
	},
	"claypot": {
		"id": "claypot",
		"name": "Blumentopf",
		"category": "deco",
		"icon": "🪴",
		"size": 1,
		"is_ground": false,
		"scene": "res://scenes/catalog/deco/claypot.tscn",
	},
}

const ALIASES = {
	"tile_grass": "grass",
	"tile_stone": "stone",
	"tile_wood": "wood",
	"tile_water": "water",
	"pine_tree": "pine",
	"leafy_tree": "tree",
	"flower_bed": "flowerbed",
	"street_lamp": "streetlamp",
	"town_house": "townhouse",
	"log_cabin": "logcabin",
	"picnic_table": "picnictable",
	"beer_table": "beertable",
	"flower_pot": "claypot",
	"clay_pot": "claypot",
	"fly_agaric": "mushrooms",
	"flyagaric": "mushrooms",
}

static func normalize_type(type_id: String) -> String:
	return ALIASES.get(type_id, type_id)

static func get_item(type_id: String) -> Dictionary:
	var norm = normalize_type(type_id)
	return ITEMS.get(norm, {})

static func get_items_by_category(category: String) -> Array[Dictionary]:
	var list: Array[Dictionary] = []
	for item in ITEMS.values():
		if item["category"] == category:
			list.append(item)
	return list

static func instantiate_item(type_id: String) -> Node3D:
	var item = get_item(type_id)
	if item.is_empty():
		return null
	var scene_path: String = item["scene"]
	if ResourceLoader.exists(scene_path):
		var packed: PackedScene = load(scene_path)
		if packed:
			var node = packed.instantiate() as Node3D
			return node
	return null
