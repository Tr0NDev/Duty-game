extends Node2D

@onready var management := $Management
@onready var tilemaplayer := $TileMapLayer


func _ready():
	for i in range(1, GameSettings.num_players+1):
		management.add_player(i, 300)
	
	build_map(Global.current_map_path)
	
	#management.spawn_unit(Vector2(0, -3), 1, "unit1", false)
	#management.spawn_unit(Vector2(2, 0), 2, "light_tank", false)


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

	# Calcul du décalage pour centrer la map
	var offset_x = -width / 2
	var offset_y = -height / 2

	tilemaplayer.clear()

	for y in range(height):
		for x in range(width):
			var tile_id: int = tiles[y][x]

			var real_x = int(x + offset_x)
			var real_y = int(y + offset_y)
			var pos = Vector2i(real_x, real_y)

			if tile_id in [2, 3, 4, 5]:
				tilemaplayer.set_cell(pos, tile_id, Vector2i(0,0), 0)
			else:
				tilemaplayer.set_cell(pos, 1, Vector2i(0,0), 0)

	print("Map centrée chargée :", file_path)
	spawn_buildings_from_map(json_data)
	
	

func spawn_buildings_from_map(json_data: Dictionary) -> void:
	var nbteam: Array[int] = []
	if not json_data.has("buildings"):
		return

	var buildings: Dictionary = json_data["buildings"]

	for building_type: String in buildings.keys():
		var entries: Array = buildings[building_type]

		for entry in entries:
			if not entry.has("pos") or not entry.has("team"):
				continue

			var pos_array: Array = entry["pos"]
			if pos_array.size() != 2:
				continue

			var pos := Vector2(pos_array[0], pos_array[1])
			var team: int = entry["team"]
			if team not in nbteam && team > 0:
				nbteam.append(team)

			management.spawn_building(pos, building_type, team, GameSettings.buildingincom[building_type])
	GameSettings.num_players = len(nbteam)
