extends TileMapLayer

@onready var tilemap_mov: TileMapLayer = $"../TileMap_Action"
@onready var ui_panel = $"../CanvasLayer/Stats"
@onready var building_panel = $"../CanvasLayer/BuildingPanel"
@onready var flag_panel = $"../CanvasLayer/Flag"
@onready var tilemaplayer := $"../TileMapLayer"
@onready var tilemapunit := $"../TileMap_Unit"
@onready var infoglobal = $"../CanvasLayer/InfoGlobale"
@onready var debugpanel = $"../CanvasLayer/Debug"
@onready var management := $"../Management"


var obstacle = [-1, 1, 4]
var movtiles
var attacktiles
var lastunit
var affichagebug = false


func get_movement_tiles(start: Vector2, unit: GameSettings.Unit) -> Array[Vector2]:
	var unitrange = unit.movement_range
	var result: Array[Vector2] = []
	for i in range(1, unitrange):
		result.append(Vector2(start.x+i, start.y))
	for i in range(1, unitrange):
		result.append(Vector2(start.x-i, start.y))
	for i in range(1, unitrange):
		result.append(Vector2(start.x, start.y+i))
	for i in range(1, unitrange):
		result.append(Vector2(start.x, start.y-i))
	
	if unitrange >= 3:
		result.append(Vector2(start.x+(unitrange-2), start.y+(unitrange-2)))
		result.append(Vector2(start.x+(unitrange-2), start.y-(unitrange-2)))
		result.append(Vector2(start.x-(unitrange-2), start.y+(unitrange-2)))
		result.append(Vector2(start.x-(unitrange-2), start.y-(unitrange-2)))
		
	for j in range(4):
		for i in result:
			if get_cell_source_id(i) in obstacle:
				result.erase(i)
			if get_cell_source_id(i) == 5 && unit.canclimb == false:
				result.erase(i)
				
	for unitboucle in GameSettings.unitlist:
		if unitboucle.tile_pos in result:
			result.erase(unitboucle.tile_pos)
				
	return result

func get_attack_tiles(unit: GameSettings.Unit) -> Array[Vector2]:
	var newattacktiles: Array[Vector2] = []
	var result: Array[Vector2] = []
	for i in unit.attack_range:
		newattacktiles.append(unit.tile_pos + i)
	
	for unitboucle in GameSettings.unitlist:
		if unitboucle.team != GameSettings.playerturn:
			if unitboucle.tile_pos in newattacktiles:
				result.append(unitboucle.tile_pos)
	return result



func _unhandled_input(event):
	if GameSettings.turnover == 0:
		if affichagebug == false:
			debugpanel.show_debug()
			infoglobal.show_tour(1)
			affichagebug = true
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			var tile_coords = tilemaplayer.local_to_map(tilemaplayer.get_local_mouse_position())
			
			GameSettings.debugcase = tile_coords
			debugpanel.show_debug()

			var building = management.get_building_at(tile_coords)
			var unit = management.get_unit_at(tile_coords)
			
			if GameSettings.selected == true: 
				if Vector2(tile_coords) in movtiles && lastunit.hasmov == false:  #BOUGER UNITE
					tilemapunit.move_unit(lastunit, Vector2(tile_coords))
					GameSettings.selected = false
					tilemap_mov.hide_movement()
					ui_panel.hide_panel()
					if lastunit == GameSettings.flagunit:  #exit drapeau
						flag_panel.hide_panel()
						GameSettings.flagunit = null
					if building:  #capture bat
						if building.type == "flag":
							GameSettings.flagunit = lastunit
							GameSettings.flaground = 1
							flag_panel.show_flag()
						elif building.team != GameSettings.playerturn:
							building.team = GameSettings.playerturn
							print("Batiment capture")
							
				elif Vector2(tile_coords) in attacktiles && lastunit.hasattack == false:   #ATTAQUE
					if lastunit.ammo > 0:
						var target = management.get_unit_at(Vector2(tile_coords))
						GameSettings.selected = false
						tilemapunit.attack_unit(lastunit, target)
						tilemap_mov.hide_movement()
						ui_panel.hide_panel()
						
				else:
					GameSettings.selected = false
					tilemap_mov.hide_movement()
					ui_panel.hide_panel()
			
			elif unit:   #CLIQUE SUR UNIT
				building_panel.hide_panel()
				if unit.team == GameSettings.playerturn:
					lastunit = unit
				if unit.team == GameSettings.playerturn:
					if unit.hasmov == false || unit.hasattack == false:
						movtiles = get_movement_tiles(unit.tile_pos, unit)
						attacktiles = get_attack_tiles(unit)
						if unit.hasmov == false:
							tilemap_mov.show_movement(movtiles)
						if unit.hasattack == false:
							tilemap_mov.show_attack(attacktiles)
						GameSettings.selected = true
				ui_panel.show_unit(unit)
						
			elif building:   #CLIQUE SUR BAT
				ui_panel.hide_panel()
				building_panel.show_building(building)
				
			else:  #CLIQUE VIDE
				ui_panel.hide_panel()
				building_panel.hide_panel()
