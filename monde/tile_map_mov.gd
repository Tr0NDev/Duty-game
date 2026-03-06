extends TileMapLayer

func show_movement(tiles: Array[Vector2]):
	for t in tiles:
		set_cell(t, 0, Vector2(0, 0) , 0) 

func show_attack(tiles: Array[Vector2]):
	for t in tiles:
		set_cell(t, 1, Vector2(0, 0) , 0) 

func hide_movement():
	clear()
