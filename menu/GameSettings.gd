extends Node

var num_players: int = 2
var playerturn = 1
var turnover = 0
var debugcase : Vector2

var buildinglist: Array[Building] = []
var playerlist: Array[Player] = []
var unitlist: Array[Unit] = []
var unitdata := {}
var flagunit: Unit = null
var flaground: int = 0
var flagroundneed: int
var selected = false
var buildingincom: Dictionary = {"camp": 200, "houses": 300, "flag": 0}

func get_flag_data(file_path: String) -> void:
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		print("ERREUR : impossible d'ouvrir les data flag")
		return
	
	var json_text = file.get_as_text()
	var json_data = JSON.parse_string(json_text)

	if typeof(json_data) != TYPE_DICTIONARY:
		print("ERREUR : mauvais format JSON pour flag data")
		return

	if json_data.has("flagroundneed"):
		flagroundneed = int(json_data["flagroundneed"])
	else:
		print("Attention : flagroundneed manquant dans le JSON")

	if json_data.has("unit"):
		for key in json_data["unit"].keys():
			var info = json_data["unit"][key]
			if typeof(info) == TYPE_DICTIONARY and info.has("cost") and info.has("atk"):
				unitdata[key] = [
					int(info["cost"]),
					int(info["atk"]),
					int(info["max_hp"]),
					int(info["attack_range"]),
					int(info["movement_range"]),
					int(info["ammo"]),
					bool(info["canclimb"]),
					bool(info["canattackground"]),
					bool(info["canattackair"]),
					bool(info["canattackwater"]),
					bool(info["quickattack"])
				]
			else:
				print("Format incorrect pour l'unité : ", key)

	else:
		print("Attention : 'unit' manquant dans le JSON")

func _ready():
	get_flag_data("res://data.json")

class Building:
	var tile_pos: Vector2
	var type: String
	var team: int
	var income: int
	var production: Array[String]
	var sprite: int

	func _init(tile_pos: Vector2, type: String, team: int, income: int, production: Array[String], sprite: int):
		self.tile_pos = tile_pos
		self.type = type
		self.team = team
		self.income = income
		self.production = production
		self.sprite = sprite


class Unit:
	var id : int
	var type: String
	var team : int
	var max_hp : int
	var hp : int
	var atk : int
	var attack_range : Array[Vector2]
	var movement_range : int
	var ammo : int
	var tile_pos: Vector2
	var hasmov : bool
	var spriteid : Array[int]
	var usedsprite : int
	var cost : int
	var canclimb : bool
	var canattackground: bool
	var canattackair: bool
	var canattackwater: bool
	var quickattack: bool
	var hasattack: bool

	func _init(id: int, type: String, team: int, max_hp: int, hp: int, atk: int, attack_range: Array[Vector2], movement_range: int, ammo: int, tile_pos: Vector2, hasmov: bool, spriteid: Array[int], usedsprite: int, cost: int, canclimb: bool, canattackground: bool, canattackair: bool, canattackwater: bool, quickattack: bool):
		self.id = id
		self.type = type
		self.team = team
		self.max_hp = max_hp
		self.hp = hp
		self.atk = atk
		self.attack_range = attack_range
		self.movement_range = movement_range
		self.ammo = ammo
		self.tile_pos = tile_pos
		self.hasmov = hasmov
		self.spriteid = spriteid
		self.usedsprite = usedsprite
		self.cost = cost
		self.canclimb = canclimb
		self.canattackground = canattackground
		self.canattackair = canattackair
		self.canattackwater = canattackwater
		self.quickattack = quickattack
		self.hasattack = true
		

class Player:
	var team: int
	var money: int

	func _init(team: int, money: int):
		self.team = team
		self.money = money
