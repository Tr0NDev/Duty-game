extends Control

@onready var tilemapbuilding := $"../TileMap_Building"
@onready var tilemapunit := $"../TileMap_Unit"
@onready var tilemaplayer := $"../TileMapLayer"

var next_unit_id: int = 1 

func get_unit_at(tile_coords: Vector2):
	for unit in GameSettings.unitlist:
		if unit.tile_pos == tile_coords:
			return unit
	return null
	
func get_building_at(tile_coords: Vector2):
	for building in GameSettings.buildinglist:
		if tile_coords == building.tile_pos:
			return building
	return null

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

func add_player(team: int, money: int) -> void:
	var p = GameSettings.Player.new(team, money)
	GameSettings.playerlist.append(p)

func find_player(team: int):
	for player in GameSettings.playerlist:
		if player.team == team:
			return player
	return null

func numberbuildingplayer(team: int):
	var nombre = 0
	for building in GameSettings.buildinglist:
		if building.team == team:
			nombre +=1
	return nombre
	
func calcincome(team: int):
	var total = 0
	for building in GameSettings.buildinglist:
		if building.team == team:
			total += building.income
	return total
	
func calc_attacktiles(atkrange: int):
	var result: Array[Vector2] = []
	for i in range(-atkrange, atkrange):
		for j in range(-atkrange, atkrange):
			result.append(Vector2(i, j))
	result.append(Vector2(atkrange, 0))
	result.append(Vector2(0, atkrange))
	result.append(Vector2(-atkrange, 0))
	result.append(Vector2(0, -atkrange))
	return result

func spawn_unit(tile_coords: Vector2, team: int, type: String, hasmov: bool):
	var u
	var data = GameSettings.unitdata[type]
	var atktiles = calc_attacktiles(data[3])
	
	
	if type == "unit1":
		u = GameSettings.Unit.new(next_unit_id, type, team, data[2], data[2], data[1], atktiles, data[4], data[5], tile_coords, hasmov, [0, 1, 2, 3, 4, 5, 6, 7], 0, data[0], data[6], data[7], data[8], data[9], data[10])
	elif type == "light_tank":
		u = GameSettings.Unit.new(next_unit_id, type, team, data[2], data[2], data[1], atktiles, data[4], data[5], tile_coords, hasmov, [8, 9, 10, 11, 12, 13, 14, 15], 0, data[0], data[6], data[7], data[8], data[9], data[10])
	elif type == "artillery":
		var range2 = calc_attacktiles(1) 
		for i in atktiles:
			if i in range2:
				atktiles.erase(i)
		u = GameSettings.Unit.new(next_unit_id, type, team, data[2], data[2], data[1], atktiles, data[4], data[5], tile_coords, hasmov, [16, 17, 18, 19, 20, 21, 22, 23], 0, data[0], data[6], data[7], data[8], data[9], data[10])
	GameSettings.unitlist.append(u)
	tilemapunit.spawn_unit(tile_coords, u)
	if hasmov:
		tilemapunit.set_unit_grayscale(u, true)
	next_unit_id += 1
	return u

func kill_unit(unit: GameSettings.Unit):
	if GameSettings.unitlist.has(unit):
		GameSettings.unitlist.erase(unit)
		tilemapunit.hide_unit(unit)
