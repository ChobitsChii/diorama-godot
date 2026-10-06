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
	"bench": {
		"id": "bench",
		"name": "Gartenbank",
		"category": "buildings",
		"icon": "🪑",
		"size": 1,
		"is_ground": false,
		"scene": "res://scenes/catalog/buildings/bench.tscn",
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
}

static func get_item(type_id: String) -> Dictionary:
	return ITEMS.get(type_id, {})

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
