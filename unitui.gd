extends Node2D

@onready var hp_label: Label = $Label
var unit: GameSettings.Unit
var tilemap: TileMapLayer

func _process(_delta):
	if unit == null:
		return

	var world_pos = tilemap.map_to_local(unit.tile_pos)
	position = world_pos + Vector2(0, 5)

	var hp = ceil(float(unit.hp) / 10)
	hp_label.text = str(hp)

	if unit.hp < unit.max_hp * 0.3:
		hp_label.modulate = Color.RED
	else:
		hp_label.modulate = Color.WHITE
