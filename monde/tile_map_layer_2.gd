extends TileMapLayer

@onready var hover: TileMapLayer = $"../TileMap_Hover"
@onready var map: TileMapLayer = $"../TileMapLayer"
var last_coords := Vector2(-999, -999)


func _process(delta):
	if GameSettings.turnover == 1:
		hover.clear()
	else:
		var mouse_world = get_global_mouse_position()
		var tile_coords = Vector2(local_to_map(to_local(mouse_world)))
		
		if map.get_cell_source_id(tile_coords) != -1:
			if tile_coords != last_coords:
				last_coords = tile_coords
				update_hover(tile_coords)

func update_hover(coords: Vector2):
	hover.clear()
	hover.set_cell(coords, 0, Vector2(0, 0), 0)

func clear_hover():
	hover.clear()
