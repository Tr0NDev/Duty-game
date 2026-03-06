extends TileMapLayer

@onready var management := $"../Management"
@onready var map: TileMapLayer = $"../TileMapLayer"

func spawn_unit(tiles: Vector2, unit: GameSettings.Unit):
	set_cell(tiles, unit.spriteid[unit.usedsprite], Vector2(0, 0), 0)

	var ui = preload("res://monde/unitui.tscn").instantiate()
	ui.unit = unit
	ui.tilemap = self
	add_child(ui)

func orientation_unit(unit: GameSettings.Unit, target: Vector2):
	set_cell(unit.tile_pos, -1, Vector2(0, 0) , 0)
	var dir = target - unit.tile_pos
	if abs(dir.x) > abs(dir.y):
		if dir.x > 0:
			set_cell(unit.tile_pos, unit.spriteid[3], Vector2(0, 0) , 0)
			unit.usedsprite = 3 
		else:
			set_cell(unit.tile_pos, unit.spriteid[0], Vector2(0, 0) , 0)
			unit.usedsprite = 0
	else:
		if dir.y > 0:
			set_cell(unit.tile_pos, unit.spriteid[1], Vector2(0, 0) , 0)
			unit.usedsprite = 1
		else:
			set_cell(unit.tile_pos, unit.spriteid[2], Vector2(0, 0) , 0)
			unit.usedsprite = 2 


func move_unit(unit: GameSettings.Unit, tiles: Vector2):
	unit.hasmov = true
	orientation_unit(unit, tiles)
	set_cell(unit.tile_pos, -1, Vector2(0, 0) , 0) 
	set_cell(tiles, unit.spriteid[unit.usedsprite], Vector2(0, 0) , 0) 
	unit.tile_pos = tiles
	if unit.quickattack == false:
		unit.hasattack = true
		set_unit_grayscale(unit, true)
	var attacktiles: Array[Vector2]
	for i in unit.attack_range:
		i += unit.tile_pos
		attacktiles.append(i)
	var troupe = false
	for i in GameSettings.unitlist:
		if i.tile_pos in attacktiles:
			troupe = true
	print(troupe)
	if troupe == false:
		print("ok")
		set_unit_grayscale(unit, true)


func calculer_degats(unit: GameSettings.Unit):
	return round(unit.atk * float(float(unit.hp) / float(unit.max_hp)))
	
func auto_reply(unit: GameSettings.Unit, target: GameSettings.Unit):
	var unittiles: Array[Vector2]
	for i in unit.attack_range:
		unittiles.append(i + unit.tile_pos)

	if target.tile_pos in unittiles:
		unit.ammo -= 1
		orientation_unit(unit, target.tile_pos)
		target.hp -= calculer_degats(unit)
		if target.hp <= 0:
			management.kill_unit(target)

func attack_unit(unit: GameSettings.Unit, target: GameSettings.Unit):
	unit.hasattack = true
	unit.hasmov = true
	unit.ammo -= 1
	orientation_unit(unit, target.tile_pos)
	target.hp -= calculer_degats(unit)
	if target.hp <= 0:
		management.kill_unit(target)
	elif target.ammo > 0:
		auto_reply(target, unit)
	set_unit_grayscale(unit, true)

func hide_unit(unit: GameSettings.Unit):
	set_cell(unit.tile_pos, -1, Vector2(0, 0) , 0) 

func set_unit_grayscale(unit: GameSettings.Unit, enable_grayscale: bool):
	if unit.usedsprite <= 3 && enable_grayscale == false:
		return
	if unit.usedsprite > 4 && enable_grayscale == true:
		return
	if enable_grayscale:
		unit.usedsprite = unit.usedsprite + 4
		print(unit.usedsprite + unit.spriteid[0])
		set_cell(unit.tile_pos, unit.usedsprite + unit.spriteid[0], Vector2(0, 0) , 0)
	else:
		unit.usedsprite = unit.usedsprite - 4
		set_cell(unit.tile_pos, unit.usedsprite + unit.spriteid[0], Vector2(0, 0) , 0)
