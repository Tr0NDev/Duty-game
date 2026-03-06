extends Panel

@onready var tourlabel: Label = $Tour
@onready var management := $"../../Management"


func show_tour(team: int):
	var player = management.find_player(team)
	tourlabel.text = "Team: " + str(team) + "\nMoney: " + str(player.money)
	visible = true

func show_panel():
	visible = true

func hide_panel():
	visible = false
