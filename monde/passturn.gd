extends Control

@onready var rideaucolor = $"Rideau"
@onready var boutonrideau = $"ButtonRideau"
@onready var texte = $"Label"
@onready var statspanel = $"../CanvasLayer/Stats"
@onready var suivantpanel = $"../CanvasLayer/SuivantPanel"
@onready var globalepanel = $"../CanvasLayer/InfoGlobale"
@onready var buildingpanel = $"../CanvasLayer/BuildingPanel"
@onready var flagpanel = $"../CanvasLayer/Flag"
@onready var debugpanel = $"../CanvasLayer/Debug"
@onready var management := $"../Management"
@onready var action := $"../TileMap_Action"
@onready var tilemapunit := $"../TileMap_Unit"

@export var game_scene_path: String = "res://menu/menu.tscn"

func _ready():
	rideaucolor.visible = false
	boutonrideau.visible = false
	texte.visible = false

func checkmort(player: GameSettings.Player):
	for unit in GameSettings.unitlist:
		if unit.team == player.team:
			return false
	for building in GameSettings.buildinglist:
		if building.team == player.team:
			return false
	return true


func nextturn():
	GameSettings.selected = false
	var nb = len(GameSettings.playerlist)
	for player in GameSettings.playerlist:
		if checkmort(player):
			nb -= 1
			GameSettings.playerlist.erase(player)
	
	if nb == 1:
		var game_scene: PackedScene = load(game_scene_path)
		get_tree().change_scene_to_packed(game_scene)
	else:
		print("Tour suivant")
		
		for unit in GameSettings.unitlist:
			unit.hasmov = false
			unit.hasattack = false
			tilemapunit.set_unit_grayscale(unit, false)
		
		GameSettings.turnover = 1
		
		var player = management.find_player(GameSettings.playerturn)
		player.money += management.calcincome(player.team)
		
		statspanel.hide_panel()
		suivantpanel.hide_panel()
		globalepanel.hide_panel()
		debugpanel.hide_panel()
		buildingpanel.hide_panel()
		flagpanel.hide_panel()
		
		action.hide_movement()
	
	GameSettings.playerturn += 1
	if GameSettings.playerturn > GameSettings.num_players:
		GameSettings.playerturn = 1
	
	if GameSettings.flagunit != null:
		if GameSettings.flagunit.team == GameSettings.playerturn:
			if management.get_building_at(GameSettings.flagunit.tile_pos) != null:
				if management.get_building_at(GameSettings.flagunit.tile_pos).type == "flag":
					GameSettings.flaground += 1
				else:
					GameSettings.flaground = 0
					GameSettings.flagunit = null
			else:
				GameSettings.flaground = 0
				GameSettings.flagunit = null
	
	if GameSettings.flaground == GameSettings.flagroundneed+1:
		var game_scene: PackedScene = load(game_scene_path)
		get_tree().change_scene_to_packed(game_scene)
		
	texte.text = "Next, Player " + str(GameSettings.playerturn)
	rideaucolor.visible = true
	boutonrideau.visible = true
	texte.visible = true

func _on_button_rideau_pressed() -> void:
	rideaucolor.visible = false
	boutonrideau.visible = false
	texte.visible = false
	globalepanel.show_tour(GameSettings.playerturn)
	suivantpanel.show()
	GameSettings.turnover = 0
	if GameSettings.flagunit != null:
		flagpanel.show_flag()
