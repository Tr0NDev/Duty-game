extends Node2D

@onready var tilemaplayer := $TileMapLayer
@onready var tilemapbuilding := $TileMap_Building

@export var game_scene_path: String = "res://menu/menu.tscn"
@onready var palette_tiles := $CanvasLayer/Tiles/HBoxContainer
@onready var palette_buildings := $CanvasLayer/Buildings/HBoxContainer
@onready var nombre_label: Label = $CanvasLayer/Buildings/Label


const BLOCKS := {
	"gomme": -1,
	"test": 1,
	"grass": 2,
	"forest": 3,
	"water": 4,
	"mountain": 5
}

const BUILDINGS := {
	"gomme": -1,
	"camp": 0,
	"houses": 1,
	"flag": 2
}

const BUILDING_TEXTURE_PATH := "res://sprite/building/"
const BLOCK_TEXTURE_PATH := "res://sprite/world/"

enum PlacementMode { TILE, BUILDING }
var placement_mode := PlacementMode.TILE

var selected_building_type := ""
var map_path: String
var used_cell: int = 4
var selected_team: int = 0

func _ready():
	build_map(Global.current_map_path)
	create_palette()
	create_building_palette()
	nombre_label.text = str(selected_team)

func spawn_building(tile_pos: Vector2, type: String, team: int, income: int):
	var b
	if type == "camp":
		b = GameSettings.Building.new(tile_pos, type, team, income, ["unit1", "light_tank","artillery"], 0)
		tilemapbuilding.set_cell(tile_pos, b.sprite, Vector2(0, 0), 0)
	elif type == "houses":
		b = GameSettings.Building.new(tile_pos, type, team, income, [], 1)
		tilemapbuilding.set_cell(tile_pos, b.sprite, Vector2(0, 0), 0)
	elif type == "flag":
		b = GameSettings.Building.new(tile_pos, type, team, income, [], 2)
		tilemapbuilding.set_cell(tile_pos, b.sprite, Vector2(0, 0), 0)
	GameSettings.buildinglist.append(b)
	print("Building placé :", b.tile_pos, " / team:", b.team, " / id:", b.type)


func load_buildings(json_data: Dictionary) -> void:
	if not json_data.has("buildings"):
		return

	var buildings: Dictionary = json_data["buildings"]

	for building_type: String in buildings.keys():
		var list: Array = buildings[building_type]

		for entry in list:
			if not entry.has("pos") or not entry.has("team"):
				continue

			var pos_array: Array = entry["pos"]
			if pos_array.size() != 2:
				continue

			var tile_pos := Vector2(pos_array[0], pos_array[1])
			var team: int = entry["team"]

			var income := 0

			spawn_building(tile_pos, building_type, team, income)


func build_map(file_path: String) -> void:
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		print("ERREUR : impossible d'ouvrir la map")
		return
	
	var json_text = file.get_as_text()
	var json_data = JSON.parse_string(json_text)

	if typeof(json_data) != TYPE_DICTIONARY:
		print("ERREUR : mauvais format JSON")
		return

	var tiles = json_data.get("tiles", [])
	var width = len(tiles[0])
	var height = len(tiles)

	tilemaplayer.clear()

	for y in range(height):
		for x in range(width):
			var tile_id: int = tiles[y][x]

			var real_x = int(x + (-width / 2))
			var real_y = int(y + (-height / 2))
			var pos = Vector2(real_x, real_y)

			if tile_id in [2, 3, 4, 5]:
				tilemaplayer.set_cell(pos, tile_id, Vector2(0,0), 0)
			else:
				tilemaplayer.set_cell(pos, 1, Vector2(0,0), 0)

	print("Map centrée chargée :", file_path)
	load_buildings(json_data)
	
	
func create_palette() -> void:
	for block_name: String in BLOCKS.keys():
		var tile_id: int = BLOCKS[block_name]

		var btn := TextureButton.new()
		btn.custom_minimum_size = Vector2(64, 64)
		btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		btn.stretch_mode = TextureButton.STRETCH_SCALE

		var texture_path: String = BLOCK_TEXTURE_PATH + block_name + ".png"
		if ResourceLoader.exists(texture_path):
			btn.texture_normal = load(texture_path)
		else:
			print("Texture manquante :", texture_path)

		btn.pressed.connect(on_tile_selected.bind(tile_id))
		palette_tiles.add_child(btn)

func create_building_palette() -> void:
	for building_name: String in BUILDINGS.keys():
		var btn := TextureButton.new()
		btn.custom_minimum_size = Vector2(64, 64)
		btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		btn.stretch_mode = TextureButton.STRETCH_SCALE

		var texture_path := BUILDING_TEXTURE_PATH + building_name + ".png"
		if ResourceLoader.exists(texture_path):
			btn.texture_normal = load(texture_path)
		else:
			print(texture_path)

		btn.pressed.connect(on_building_selected.bind(building_name))
		palette_buildings.add_child(btn)

func on_building_selected(building_type: String) -> void:
	placement_mode = PlacementMode.BUILDING
	selected_building_type = building_type
	print("Bâtiment sélectionné :", building_type)


func on_tile_selected(tile_id: int) -> void:
	placement_mode = PlacementMode.TILE 
	used_cell = tile_id
	print("Bloc sélectionné :", tile_id)



func save_map() -> void:
	var map_path = Global.current_map_path
	if map_path == "" or map_path == null:
		print("ERREUR : map_path vide, impossible de sauvegarder")
		return

	var file = FileAccess.open(map_path, FileAccess.WRITE)
	if file == null:
		print("ERREUR : impossible d'écrire dans", map_path)
		return

	var used_cells = tilemaplayer.get_used_cells()

	if used_cells.size() == 0:
		print("ERREUR : Tilemap vide")
		return
		
	var min_x = 999999
	var max_x = -999999
	var min_y = 999999
	var max_y = -999999

	for cell in used_cells:
		min_x = min(min_x, cell.x)
		max_x = max(max_x, cell.x)
		min_y = min(min_y, cell.y)
		max_y = max(max_y, cell.y)

	var width = max_x - min_x + 1
	var height = max_y - min_y + 1

	var tiles = []
	for y in range(height):
		var row = []
		for x in range(width):
			row.append(2) 
		tiles.append(row)

	for cell in used_cells:
		var local_x = cell.x - min_x
		var local_y = cell.y - min_y
		var tile_data = tilemaplayer.get_cell_source_id(cell)
		if tile_data == -1:
			tiles[local_y][local_x] = 2
		else:
			tiles[local_y][local_x] = tile_data

	var json_data = {
		"width": width,
		"height": height,
		"tiles": tiles
	}

	var json_text = JSON.stringify(json_data)

	file.store_string(json_text)
	file.close()

	print("Map sauvegardée dans :", map_path)


func save_buildings() -> void:
	var file := FileAccess.open(Global.current_map_path, FileAccess.READ)
	var json_data: Dictionary = JSON.parse_string(file.get_as_text())
	file.close()

	if not json_data.has("buildings"):
		json_data["buildings"] = {}

	json_data["buildings"].clear()

	for b in GameSettings.buildinglist:
		if not json_data["buildings"].has(b.type):
			json_data["buildings"][b.type] = []

		json_data["buildings"][b.type].append({
			"pos": [b.tile_pos.x, b.tile_pos.y],
			"team": b.team
		})

	file = FileAccess.open(Global.current_map_path, FileAccess.WRITE)
	file.store_string(JSON.stringify(json_data, "\t"))
	file.close()

	
func _unhandled_input(event):
	if not (event is InputEventMouseButton and event.pressed):
		return

	var tile_pos : Vector2 = tilemaplayer.local_to_map(tilemaplayer.get_local_mouse_position())

	if event.button_index == MOUSE_BUTTON_LEFT:
		if placement_mode == PlacementMode.TILE:
			if used_cell == -1:
				tilemaplayer.set_cell(tile_pos, used_cell, Vector2.ZERO, 0)
			else:
				tilemaplayer.set_cell(tile_pos, used_cell, Vector2.ZERO, 0)
			save_map()
		elif placement_mode == PlacementMode.BUILDING:
			print(selected_team)
			if selected_building_type != "gomme":
				if selected_building_type == "flag":
					spawn_building(tile_pos, selected_building_type, 0, 0)
				else:
					spawn_building(tile_pos, selected_building_type, selected_team, 0)
			else:
				remove_building_at(tile_pos)
			save_buildings()

func remove_building_at(tile_pos: Vector2) -> void:
	tilemapbuilding.set_cell(tile_pos, -1, Vector2.ZERO, 0)

	for i in range(GameSettings.buildinglist.size() - 1, -1, -1):
		var b = GameSettings.buildinglist[i]
		if b.tile_pos == tile_pos:
			GameSettings.buildinglist.remove_at(i)
			print("Building supprimé à :", tile_pos)
			break

func _on_team_spinbox_value_changed(value: float) -> void:
	selected_team = int(value)
	print("Team sélectionnée :", selected_team)


func _on_suivant_pressed() -> void:
	var game_scene: PackedScene = load(game_scene_path)
	get_tree().change_scene_to_packed(game_scene)


func _on_plus_pressed() -> void:
	if selected_team < 4:
		selected_team += 1
		nombre_label.text = str(selected_team)


func _on_moins_pressed() -> void:
	if selected_team > 0 :
		selected_team -= 1
		nombre_label.text = str(selected_team)
